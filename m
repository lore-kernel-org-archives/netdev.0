From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH]-bonding: Fix slave link failure count update failure
Date: Mon, 15 Dec 2008 09:05:32 -0800
Message-ID: <9002.1229360732@death.nxdomain.ibm.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE511805@blrx3m08.blr.amer.dell.com>
Cc: netdev@vger.kernel.org
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33779 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133AbYLORFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 12:05:39 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBFH4pt8018407
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 12:04:51 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBFH5a2u154530
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 12:05:36 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBFH5ZAG015750
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 12:05:35 -0500
In-reply-to: <EDA0A4495861324DA2618B4C45DCB3EE511805@blrx3m08.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<Narendra_K@Dell.com> wrote:
[...]
>The "bonding: refactor mii monitor" patch (
>http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.27.y.git;a=co
>mmit;h=f0c76d61779b153dbfb955db3f144c62d02173c2) misses updating the
>slave link failure count. So "cat /proc/net/bonding/bond0" doesn't
>reflect the no of slave link failures. The patch addresses it.

	This is already fixed in mainline by:

commit fba4acda35f3119328bcba28aacefae14245d2bb
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Thu Oct 30 17:41:14 2008 -0700

    bonding: fix miimon failure counter

	Note that the two patches add the increment to different places,
so applying both of them will result in double increments.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
