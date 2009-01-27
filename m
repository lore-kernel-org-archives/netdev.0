From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: IFF_RUNNING without carrier after reboot
Date: Tue, 27 Jan 2009 11:32:36 -0500
Message-ID: <20090127163236.GA26065@csclub.uwaterloo.ca>
References: <20081214.222951.190945313.davem@davemloft.net> <E1LC7s0-0007qm-T3@gondolin.me.apana.org.au> <20081214.233625.36638431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, marcel@holtmann.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:50317 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753723AbZA0Qch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:32:37 -0500
Content-Disposition: inline
In-Reply-To: <20081214.233625.36638431.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 14, 2008 at 11:36:25PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 15 Dec 2008 18:28:00 +1100
> 
> > David Miller <davem@davemloft.net> wrote:
> > >
> > > The RUNNING state has no connection to link presence.
> > > 
> > > It just means that the device has been brought up by a
> > > user configuration command like the ifconfig you ran.
> > > 
> > > It really means nothing else.
> > 
> > Well RUNNING did use to indicate carrier state.  In fact I didn't
> > even know that it had changed until this email :)
> > 
> > This is the changeset which did it:
> 
> Yes, it was a bug and we fixed it more than 2 years ago.
> Thanks for confirming :-)

So the RUNNING flag no longer indicates link state?  Wow that's going to
break some userspace quite badly.

Isn't the UP flag what indicates opstate?

What is the correct way for userspace to detect link state on an
interface?

-- 
Len Sorensen
