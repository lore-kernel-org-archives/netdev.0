From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 22:36:17 +0300
Message-ID: <200808172236.17857.denys@visp.net.lb>
References: <20080815190905.M56388@visp.net.lb> <200808171603.22151.denys@visp.net.lb> <20080817133608.GA3584@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:48786 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbYHQTh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 15:37:29 -0400
In-Reply-To: <20080817133608.GA3584@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am lost in patches :-)
When you will be back, let me know if order and set of patches is correct.
Here is what i am using:

http://www.nuclearcat.com/patches/00-prevfixes1.patch
http://www.nuclearcat.com/patches/00-prevfixes2.patch
http://www.nuclearcat.com/patches/01-take3.patch
http://www.nuclearcat.com/patches/02-fix1.patch
http://www.nuclearcat.com/patches/03-fix_patch_2.patch

And thanks for your help!
I cannot take risk and put to wide production, since it is crashing sometimes, 
but i guess in few days we can make it ready for production.

On Sunday 17 August 2008, Jarek Poplawski wrote:
> On Sun, Aug 17, 2008 at 04:03:22PM +0300, Denys Fedoryshchenko wrote:
> > All patches applied.
> > On normal shaper i got just this warning mentioned before.
> > On alternative shaper (it is not using TBF anymore, it is using flow
> > classifier and many HTB classes) - it is panicing.
> >
> > After applying all rules, most probably it is happened when some traffic
> > passed over there. I can't be absolutely sure in that, but it looks like
> > at that time there is no actions by iproute2/tc done. Just traffic.
> >
> > This is same PC where WARNING appeared which i mention in previous mail.
> > So maybe it is result of that warning, no idea...
>
> BTW, I'll have to have a break for today, so I'll be able to respond
> only tomorrow. Your testing is very valuable and this all needs
> rethinking, but as before, I doubt current -rc is good choice for
> production.
>
> Cheers,
> Jarek P.


