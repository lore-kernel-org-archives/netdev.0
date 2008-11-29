From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Realtek 8169 problems with net booting
Date: Sat, 29 Nov 2008 22:47:40 +0000
Message-ID: <20081129224740.GU28946@ZenIV.linux.org.uk>
References: <20081124181456.66a967d2@lxorguk.ukuu.org.uk> <20081129204416.GA6401@electric-eye.fr.zoreil.com> <20081129210600.GT28946@ZenIV.linux.org.uk> <20081129212830.GA5846@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53171 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbYK2Wrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 17:47:42 -0500
Content-Disposition: inline
In-Reply-To: <20081129212830.GA5846@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 29, 2008 at 10:28:30PM +0100, Francois Romieu wrote:
> Al Viro <viro@ZenIV.linux.org.uk> :
> [...]
> > Other symptoms: it kept trying to renegotiate the link every few seconds.
> 
> [...]
> > Hang used to happen on the first incoming packet after boot, _but_ that
> > didn't happen on each boot.
> 
> Ok, it is consistent with a dma at (more or less) random location.
> 
> Thanks for the report Al.
> 
> Can you send the "XID" line printed by the driver on recent kernels so
> that I can figure the specific version of the chipset / PHY ?

Interesting...

Working one -
eth0: RTL8110s at 0xffffc200008b6000, 00:01:80:50:a2:f1, XID 04000000 IRQ 23
B0rken -
eth0: RTL8169s at 0xffffc2000017c000, 00:01:80:4d:0b:3b, XID 00800000 IRQ 23

Note: that's from the logs - I won't get around to testing that stuff until
tomorrow afternoon.
