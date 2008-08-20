From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 19:33:20 +0200
Message-ID: <1219253600.7591.352.camel@violet.holtmann.net>
References: <20080819.041706.261399060.davem@davemloft.net>
	 <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
	 <1219170451.7591.175.camel@violet.holtmann.net>
	 <alpine.LFD.1.10.0808191348540.3324@nehalem.linux-foundation.org>
	 <1219203753.7591.205.camel@violet.holtmann.net>
	 <20080820143734.GB20632@tuxdriver.com>
	 <alpine.LFD.1.10.0808200826530.3324@nehalem.linux-foundation.org>
	 <1219246813.7591.347.camel@violet.holtmann.net>
	 <alpine.LFD.1.10.0808200853410.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:51027 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbYHTRdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 13:33:15 -0400
In-Reply-To: <alpine.LFD.1.10.0808200853410.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

> > John was just pointing out (like myself before) that a lot of people are
> > under the impression that documentation updates and new drivers should
> > not be queued up and merged as soon as possible.
> 
> I think (and hey, I'm flexible, and we can discuss this) that the rules 
> should be:
> 
>  - by default, the answer should always be "don't push anything after the 
>    merge window unless it fixes a regression or a nasty bug".
> 
>    Here "nasty bug" is something that is a problem in practice, and not 
>    something theoretical that people haven't really reported.
> 
>  - but as a special case, we relax that for totally new drivers (and that 
>    includes things like just adding a new PCI or USB ID's to old drivers), 
>    because (a) it can't really regress and (b) support for a specific 
>    piece of hardware can often be critical.
> 
> With regard to that second case, I'd like to note that obviously even a 
> totally new driver _can_ regress, in the sense that it can cause build 
> errors, or problems that simply wouldn't have happened without that 
> driver. So the "cannot regress" obviously isn't strictly true, but I 
> think everybody understands what I really mean.
> 
> It should also be noted that the "new driver" exception should only be an 
> issue for things that _matter_.
> 
> For example, a machine without networking support (or without suppoort for 
> a some other really core driver that provides basic functionality) is 
> practically useless. But a machine without support for some particular 
> webcam or support for some special keys on a particular keyboard? That 
> really doesn't matter, and might as well wait for the next release.
> 
> So the "merge drivers early" is for drivers that reasonably _matter_ in 
> the sense that it allows people to test Linux AT ALL on the platform. It 
> shouldn't be "any possible random driver".
> 
> IOW, think about the drivers a bit like a distro would think about 
> backporting drivers to a stable kernel. Which ones are really needed? 
> 
> Also, note that "new driver" really should be that. If it's an older 
> driver, and you need to touch _any_ old code to add a new PCI ID or 
> something, the whole argument about it not breaking falls away. Don't do 
> it. I think, for example, that the SCSI people seem to be a bit too eager 
> sometimes to update their drivers for new revisions of cards, and they do 
> it to old drivers.
> 
> And finally - the rules should be guidelines. It really isn't always 
> black-and-white, but most of the time the simple question of "could this 
> _possibly_ be just queued for the next release without hurting anything" 
> should be the basic one. If the answer is "yes", then wait.

I am perfectly fine with these rules. You only had to spell them out :)

Regards

Marcel


