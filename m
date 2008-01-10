From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: No idea about shaping trough many pc
Date: Thu, 10 Jan 2008 12:06:35 +0300
Message-ID: <4785E01B.3080900@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:38802 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573AbYAJJGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 04:06:43 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 84671A6C1F7
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 12:06:42 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kfvGs5f+aF1P for <netdev@vger.kernel.org>;
	Thu, 10 Jan 2008 12:06:36 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 78C99A6C1F4
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 12:06:36 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.
I try more then 2 month resolve problem witch my shaping.  Maybe you can 
help for me?

Sheme:
                                +-------------------+
                     + ----- | Shaping PC 1 | ---------+
                     /          +-------------------+              \
+--------+   /           +--------------------+              \          
+ --------+
| Cisco |  +-------- | Shaping PC N  | -----------+ -----| CISCO |
+--------+   \           +--------------------+              /          
+---------+
                     \          +---------------------+           /
                     + ----- | Shaping PC 20 | --------+
                                +---------------------+

Network - Over 10k users. Common bandwidth to INTERNET more then 1 GBs
All computers have BGP and turn on multipath.
Cisco can't do load sharing by Packet (its can resolve all my problems 
=((( ). Only by DST IP, SRC IP, or +Level4.
Ok. User must have speed 1mbs.
Lets look variants:
1. Create rules to user = (1mbs/N computers). If user use N connection 
all great, but if it use 1 connection his speed = 1mbs/N - its not look 
good. All be great if cisco can PER PACKET load sharing =(
2. Create rules to user = 1mbs. If user use 1 connection all great, but 
if it use N connection his speed much more then needed limit =(

Why i use 20 PC? Becouse 1 pc normal forward 100-150mbs... when it have 
100% cpu usage on Sofware Interrupts...

Any idea how to resolve this problem?

In my dreams (feature request to netdev ;) ):
Get PC - title: MASTER TC.  All 20 PC syncronize statistic with MASTER 
and have common rules and statistic. Then i use variant 2 and will be 
happy... but its not real? =(
Maybe have other variants?


Thanks for help!
Slavon.
P.S. Sorry for my english =(
