From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Sun, 11 Jan 2009 13:39:29 -0800 (PST)
Message-ID: <20090111.133929.57600645.davem@davemloft.net>
References: <43805.1231672258@turing-police.cc.vt.edu>
	<20090111.040842.86784676.davem@davemloft.net>
	<1231676698.25018.147.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38330
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752924AbZAKVj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 16:39:29 -0500
In-Reply-To: <1231676698.25018.147.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 11 Jan 2009 12:24:58 +0000

> Other drivers will load the firmware later, at the time the device is
> brought up. This means that even if you build the driver into the kernel
> without its firmware, it can still request the firmware later, when you
> try to start _using_ it. And when the file system is available.

For example, for mounting an NFS root using that device.... Oh, will I
need an initramfs for that once you pull the firmware-in-kernel
option?

To me, device probe is in fact the place to fail firmware discovery
for networking devices.  Because such a failure can mean you can't
mount your root filesystem.
