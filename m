From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Tue, 02 May 2006 23:32:46 -0700 (PDT)
Message-ID: <20060502.233246.92272407.davem@davemloft.net>
References: <44578691.4020402@corky.net>
	<200605021802.43301.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marc@corky.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32957
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964887AbWECGd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 02:33:27 -0400
To: ak@suse.de
In-Reply-To: <200605021802.43301.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Tue, 2 May 2006 18:02:43 +0200

> On Tuesday 02 May 2006 18:19, Just Marc wrote:
> 
> > I thought that maybe it's time to either set TCP_DEBUG to 0 or 
> > alternatively allow an admin to toggle the printing of this message 
> > off/on?  On a few busy web servers running usually latest versions of 
> > 2.6 I have this message displaying hundreds (if not more) times a day, 
> 
> You're talking to a lot of broken TCP clients then.

Herbert Xu also fixed a bug that would cause that message
to be emitted erroneously, 9 times out of 10 that is why
people are seeing these messages.

I think disabling that message is a non-starter, we want to
see the message because as we've seen it can point to bugs
on our end too.
