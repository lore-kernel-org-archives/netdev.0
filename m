From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add netconsole support for xen-netfront
Date: Tue, 24 Jan 2012 23:00:42 -0500 (EST)
Message-ID: <20120124.230042.1180973944381398704.davem@davemloft.net>
References: <4F173467.90106@oracle.com>
	<20120123182443.GA22963@phenom.dumpdata.com>
	<1327395480.17019.1.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, tina.yang@oracle.com,
	zhenzhong.duan@oracle.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gurudas.pai@oracle.com, jeremy@goop.org
To: Ian.Campbell@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327395480.17019.1.camel@dagon.hellion.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Tue, 24 Jan 2012 08:58:00 +0000

> On Mon, 2012-01-23 at 18:24 +0000, Konrad Rzeszutek Wilk wrote:
> 
>> From 1c265b7946f222ab6a5aac5245a0ab84618772c8 Mon Sep 17 00:00:00 2001
>> From: Zhenzhong Duan <zhenzhong.duan@oracle.com>
>> Date: Thu, 12 Jan 2012 10:18:29 +0800
>> Subject: [PATCH] xen/netfront: add netconsole support.
>> 
>> add polling interface to xen-netfront device to support netconsole
>> 
>> This patch also alters the spin_lock usage to use irqsave variant.
>> Documentation/networking/netdevices.txt states that start_xmit
>> can be called with interrupts disabled by netconsole and therefore using
>> the irqsave/restore locking in this function is looks correct.
>> 
>> Signed-off-by: Tina.Yang <tina.yang@oracle.com>
>> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
>> Signed-off-by: Zhenzhong.Duan <zhenzhong.duan@oracle.com>
>> Tested-by: gurudas.pai <gurudas.pai@oracle.com>
>> [v1: Copy-n-pasted Ian Campbell comments]
>> Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
