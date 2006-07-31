From: Christophe Devriese <Christophe.Devriese@eurid.eu>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Mon, 31 Jul 2006 18:48:21 +0200
Message-ID: <200607311848.22451.Christophe.Devriese@eurid.eu>
References: <44CA34D0.1070507@candelatech.com> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060731123038.GA10138@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from uu212-190-206-99.unknown.uunet.be ([212.190.206.99]:29931 "EHLO
	smtp.eurid.eu") by vger.kernel.org with ESMTP id S1030237AbWGaQsc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 12:48:32 -0400
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
In-Reply-To: <20060731123038.GA10138@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 31 July 2006 14:30, you wrote:
> (This is not directed at Christophe, or anyone in particular...)
>
> <rant>
>
> Am I the only one that thinks that our handling of LAN L2 stuff
> is at best a little "too" flexible (and at worst a collection of
> nasty hacks)?
>
> I mean, do we really need both the ability to bond multiple vlan
> interfaces AND the ability to have vlan interfaces on top of a bond?
> How many people really appreciate the subtle(?) differences?
>
> Then throw bridging into the mix!  If I'm using VLANs and bonds in
> a bridged environment, do I bridge the bonds, or bond the bridges?

In all honesty, you cannot bond bridges :-p

> Do the VLANs come before the bonds?  after the bridges?  or somewhere
> in-between?  Do all these combinations even work together?  Who has
> the definitive answer (besides the code itself)?
>
> I have no doubt that there are plenty of opportunities for cleverness
> here (and no doubt dragons too).  I just doubt that most of them
> are worth the complexities introduced by our current collection of
> "transparently" stackable pseudo-drivers and strategically placed hacks
> (e.g. skb_bond).  All that, and it still isn't clear to me how we
> can cleanly accomodate 802.1s (which adds VLAN awareness to bridging).
>
> Do we hold the view that our L2 code is on par with the rest of
> our code?  Is there an appetite for a clean-up?  Or is it just me?

A vlan capable bridge with trunk ports and access ports would be nice :-p

I think the current code is nice. You need it to properly support 
virtualization and I find it very useful where I work to have this option.

Regards,

Christophe
