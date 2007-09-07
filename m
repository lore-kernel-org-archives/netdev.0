From: Joseph Southwell <joseph@ontoserve.com>
Subject: bug in arp handling 2.6.20
Date: Thu, 6 Sep 2007 19:41:08 -0500
Message-ID: <50155211-787D-48AE-B9D8-7FD18406C8E3@ontoserve.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-71-42-144-3.sw.biz.rr.com ([71.42.144.3]:56941 "EHLO
	mail.ontoserve.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964944AbXIGBFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 21:05:10 -0400
Received: from [71.42.144.208] (host208.ontoserve.com [71.42.144.208])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail.ontoserve.com (Postfix) with ESMTP id 6641A8B40BC
	for <netdev@vger.kernel.org>; Thu,  6 Sep 2007 19:41:08 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

scenario
Machine A
eth0 is plugged  into network.
192.168.1.201
eth0:1
192.168.1.2


Machine B
eth1 is plugged into network.
192.168.1.101
eth0 is not plugged into network. so I can test locally before  
switching the wire.
192.168.1.201
eth0:1
192.168.1.2

arp request for 192.168.1.2 is responded to by eth1 on machine B.  
That seems buggy to me. worse, it continues to do it after  
unconfiguring eth0:1 and eth0.
