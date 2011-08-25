From: "J.Hwan Kim" <frog1120@gmail.com>
Subject: how to distribute irqs of ixgbevf
Date: Thu, 25 Aug 2011 17:07:50 +0900
Message-ID: <4E5602D6.90807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50226 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab1HYIHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:07:54 -0400
Received: by yxj19 with SMTP id 19so1528433yxj.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 01:07:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, everyone

The interrupts of my ixgbevf driver occurs only Core 0
although the user space "irqbalance" serivce is working.

How can I distribute the interrupt of RX in ixgbevf to all cores?

cat /proc/interrupts | grep "isv"
   97:          8          0          0          0          0          
0          0          0   PCI-MSI-edge      isv0-rx-0
   99:          7          0          0          0          0          
0          0          0   PCI-MSI-edge      isv0:lsc
  103:       2059      0          0          0          0          
0          0          0   PCI-MSI-edge      isv2-rx-0
  104:         14        0          0          0          0          
0          0          0   PCI-MSI-edge      isv2-tx-0
  105:          1         0          0          0          0          
0          0          0   PCI-MSI-edge      isv2:mbx

"isv" is netdevice name of my ixgbevf.



Thanks in advance.

Best Regards,

J.Hwan Kim
