From: Michal Simek <monstr@monstr.eu>
Subject: Hight speed data sending from custom IP out of kernel
Date: Tue, 19 Apr 2011 11:49:21 +0200
Message-ID: <4DAD5AA1.4000900@monstr.eu>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42712 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab1DSJtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 05:49:24 -0400
Received: by bwz15 with SMTP id 15so4382239bwz.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 02:49:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to create demo for high speed data sending from custom IP through 
the ethernet. I think the best description is that there are dmaable memory 
mapped registers or just memory which store data I want to send (for example 200MB).
Linux should handle all communication between target(probably server) and host 
(client) but data in the packets should go from that custom IP and can't go 
through the kernel because of performance issue.

Ethernet core have own DMA which I could use but the question is if there is any 
option how to convince the kernel that data will go directly from memory mapped 
registers and the kernel/driver/... just setup dma BD for headers and second for 
data.

Do you have any experience with any solution with passing data completely out of 
kernel?

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
