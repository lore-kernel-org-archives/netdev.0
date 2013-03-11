From: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Subject: Trying to implement secondary loopback
Date: Mon, 11 Mar 2013 10:25:53 +0100
Message-ID: <513DA321.8070904@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:36902 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab3CKJpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 05:45:38 -0400
Received: from [172.17.131.45] (unknown [172.17.131.45])
	by mailgw.hhi.fraunhofer.de (Postfix) with ESMTP id 70E26186804C
	for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 10:26:02 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks,

I'm Thomas Martitz, working on my Master Thesis: an Ethernet NIC. As 
part of my work I want to develop a custom loopback interface (for 
testing purposes).

However I'm facing a problem: It doesn't appear to be possible for a 
second loopback device to exist. Even when copying (and module'ifying) 
drivers/net/loopback.c the resulting device doesn't behave like the 
standard lo interface.

After examing the code I found this line (in loopback_net_init()):

loopback.c:206         net->loopback_dev = dev;

This suggests that the current network namespace can only have one 
loopback interface. And indeed after modifying my custom interface to 
include this particular line it begins to work, but obviously at the 
same time the standard lo interface stops working.

So my questions are:
* Is this on purpse/expected?
* Is there anyway around it so that I can have a custom loopback 
interface without touching lo's functionality.

Many thanks in advance.

Best regards.

-----
visit us at

CeBIT 2013 / March 5-9 / Hannover, Germany / hall 9, booth E08

OFC 2013 / March 19-21 / Anaheim Convention Center, CA, USA / booth 11807

www.hhi.fraunhofer.de/events
