From: Alexey Perevalov <a.perevalov@samsung.com>
Subject: Question about packet schedulers
Date: Wed, 28 Nov 2012 16:24:42 +0400
Message-ID: <50B6028A.3050105@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:43089 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566Ab2K1MYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 07:24:45 -0500
Received: from eusync3.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0ME700JUU6HQUX70@mailout1.w1.samsung.com> for
 netdev@vger.kernel.org; Wed, 28 Nov 2012 12:25:02 +0000 (GMT)
Received: from [106.109.9.222] by eusync3.samsung.com
 (Oracle Communications Messaging Server 7u4-23.01(7.0.4.23.0) 64bit (built Aug
 10 2011)) with ESMTPA id <0ME700L7T6H7VG60@eusync3.samsung.com> for
 netdev@vger.kernel.org; Wed, 28 Nov 2012 12:24:43 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,

I need a packet scheduler with very interesting behavior.

Such packet scheduler should maximize idle time and send available 
packets on tiny time frame,
on huge time frame it should wait and accumulate packets. These time 
intervals should be tweaked.


-- 
Best regards,
Alexey Perevalov,
