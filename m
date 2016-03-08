From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Question concerning function illegal_highdma
Date: Tue, 8 Mar 2016 11:32:26 +0100
Message-ID: <56DEAA3A.4080207@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	<linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:22271 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932828AbcCHKcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 05:32:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

while trying to understand the meaning of the net_device flag NETIF_F_HIGHDMA
I came across the function illegal_highdma() which seems to perform two tasks:

1. Check if a network interface is able to handle high memory pages
2. Check if a network interface is able to handle the resulting DMA addresses

What I dont understand is why both conditions are only checked if CONFIG_HIGHMEM is set.
For 1. this makes sense, of course. But why is 2. also only checked with CONFIG_HIGHMEM?
Should not 2. always be checked, regardless of whether high memory exists in the system or not?

Thanks for any enlightenment in advance!

Regards,
Lino
