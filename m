From: Naveen BN <naveen.bn@globaledgesoft.com>
Subject: xfrm command fails
Date: Wed, 11 Nov 2009 10:58:00 +0530
Message-ID: <4AFA4B60.3090306@globaledgesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gesmail.globaledgesoft.com ([203.76.137.4]:36579 "EHLO
	gesmail.globaledgesoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750821AbZKKFsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 00:48:07 -0500
Received: from naveen.globaledgesoft.com (unknown [172.16.8.36])
	by gesmail.globaledgesoft.com (Postfix) with ESMTP id E338B17B433
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 11:18:10 +0530 (IST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All
I am trying to create a security association using ip xfrm command, but 
i get an message saying
"*RTNETLINK answers: Function not implemented*" and ip xfrm state 
succeeds in displaying  sa  written using setkey .

ip xfrm state add src 192.168.1.20 dst 192.168.1.5 proto esp spi 
0x354cb04b mode tunnel reqid 16385 replay-window 32 auth hmac 
0xecf02a5cf6568556e1bdcd961c7ec3f92afd01cc enc cbc 
0x5c0cfa9672ce67ba545b593076dfb278 sel src 0.0.0.0/0 dst 0.0.0.0/0

ERROR message => "RTNETLINK answers: Function not implemented"

Regards
Naveen
