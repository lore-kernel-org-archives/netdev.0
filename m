From: Rick Jones <rick.jones2@hp.com>
Subject: error(s) in 2.6.23-rc5 bonding.txt ?
Date: Fri, 07 Sep 2007 15:02:41 -0700
Message-ID: <46E1CA81.6050808@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:54991 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943AbXIGWDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 18:03:04 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel11.hp.com (Postfix) with ESMTP id B5B703603F
	for <netdev@vger.kernel.org>; Fri,  7 Sep 2007 15:02:52 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id PAA18040
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 15:02:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was perusing Documentation/networking/bonding.txt in a 2.6.23-rc5 tree 
and came across the following discussing the round-robin scheduling:

>         Note that this out of order delivery occurs when both the
>         sending and receiving systems are utilizing a multiple
>         interface bond.  Consider a configuration in which a
>         balance-rr bond feeds into a single higher capacity network
>         channel (e.g., multiple 100Mb/sec ethernets feeding a single
>         gigabit ethernet via an etherchannel capable switch).  In this
>         configuration, traffic sent from the multiple 100Mb devices to
>         a destination connected to the gigabit device will not see
>         packets out of order.  

My first reaction was that this was incorrect - it didn't matter if the 
receiver was using a single link or not because the packets flowing 
across the multiple 100Mb links could hit the intermediate device out of 
order and so stay that way across the GbE link.

Before I go and patch-out that text I thought I'd double check.

rick jones
