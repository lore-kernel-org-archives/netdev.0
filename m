From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Subject: Regarding sumbiting a new NIC driver to kernel.
Date: Fri, 1 Jul 2011 09:09:40 +0000
Message-ID: <6349D7A510622448B1BA0967850A843801163B91@nasanexd02d.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'davem@davemloft.net'" <'davem@davemloft.net'>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:42432 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755866Ab1GAJJp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 05:09:45 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David S. Miller

I am working for Qualcomm(Atheros) as an engineer. Recently, we are developing a new Linux driver, "alx" , that supports AR8131, AR8151, AR8152 ,  AR8161 and etc. AR8161 is our new NIC that will be released soon.

As we know, there is a linux driver "atl1c"  in the kernel. It can also support AR8131, AR8152, AR8151. So "alx" at functionality is a little repeated with "atl1c". Now,  we hope to push the new "alx" into linux kernel and remove the old "atl1c". 

Would you have any advices to us?  If this is possible, how do I submit the new driver and remove the old driver? Can you give me a doc how to submit the driver to kernel or any hints?

Btw, why do we need to develop the new driver?
The most important reason is for convenience on maintenance 1. we need to make HW operations uniform on all supported OS, such as WinXP, Win7 and Linux.
2. As our company is continuous to release new NICs, there are more and more drivers to support those NICs. It's a pity to develop and maintain so many drivers. So we have developed the driver, "alx". We will use it to support as many NICs as possible, including NICs released in future.


Thanks
Cloud

