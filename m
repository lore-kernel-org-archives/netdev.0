From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Sun, 11 Jan 2009 14:05:59 -0800 (PST)
Message-ID: <20090111.140559.126980927.davem@davemloft.net>
References: <1231676698.25018.147.camel@macbook.infradead.org>
	<20090111.133929.57600645.davem@davemloft.net>
	<1231711347.25018.658.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751193AbZAKWF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 17:05:58 -0500
In-Reply-To: <1231711347.25018.658.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 11 Jan 2009 22:02:27 +0000

> On Sun, 2009-01-11 at 13:39 -0800, David Miller wrote:
> > For example, for mounting an NFS root using that device.... Oh, will I
> > need an initramfs for that once you pull the firmware-in-kernel
> > option?
> 
> The option to build arbitrary firmware into your kernel is never going
> to be pulled. You can do nfsroot on your myri10ge today, without initrd,
> even though the firmware is distributed separately from the kernel. That
> doesn't prevent you from building it _in_ to your kernel, if you choose
> to.

So what used to work out of the box by typing make now
will have all kinds of strange depencies, right?

This is a regression, no matter how you spin it, in my
book.
