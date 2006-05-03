From: Andi Kleen <ak@suse.de>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 3 May 2006 08:52:15 +0200
Message-ID: <200605030852.16002.ak@suse.de>
References: <44578691.4020402@corky.net> <200605021802.43301.ak@suse.de> <20060502.233246.92272407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: marc@corky.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:41647 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S965114AbWECGwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 02:52:31 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060502.233246.92272407.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 03 May 2006 08:32, David S. Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Tue, 2 May 2006 18:02:43 +0200
> 
> > On Tuesday 02 May 2006 18:19, Just Marc wrote:
> > 
> > > I thought that maybe it's time to either set TCP_DEBUG to 0 or 
> > > alternatively allow an admin to toggle the printing of this message 
> > > off/on?  On a few busy web servers running usually latest versions of 
> > > 2.6 I have this message displaying hundreds (if not more) times a day, 
> > 
> > You're talking to a lot of broken TCP clients then.
> 
> Herbert Xu also fixed a bug that would cause that message
> to be emitted erroneously, 9 times out of 10 that is why
> people are seeing these messages.

Still if Marc has hundreds per day that would be still tens
per day - and someone with even more traffic than Marc
would have hundreds per day again.

> I think disabling that message is a non-starter, we want to
> see the message because as we've seen it can point to bugs
> on our end too.

Just having the counter would help with that already, no?
Also the default for the sysctl could be maybe switched in -rc* and final? 

-Andi
