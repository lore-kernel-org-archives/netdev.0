From: Rick Jones <rick.jones2@hp.com>
Subject: lowpri - RTO for unidirectional reciever
Date: Mon, 08 Dec 2008 18:02:01 -0800
Message-ID: <493DD199.6080600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:34602 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbYLICCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 21:02:08 -0500
Received: from tardy.cup.hp.com (tardy.cup.hp.com [16.89.104.60])
	by g1t0028.austin.hp.com (Postfix) with ESMTP id 562051C139
	for <netdev@vger.kernel.org>; Tue,  9 Dec 2008 02:02:04 +0000 (UTC)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id SAA16667
	for <netdev@vger.kernel.org>; Mon, 8 Dec 2008 18:02:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks -

I was going through old email to do a status report and was reminded of 
a discussion in netperf-talk that might be of interest to people here 
since it involved a Linux receiver:

http://www.netperf.org/pipermail/netperf-talk/2008-November/000478.html

A Mac OSX bug was found/presumed, but there was an interesting behaviour 
on the linux receiver side as well - the rtx of the ignored FIN happened 
after what IIRC is the initial RTO.  It suggested that the ACK of the 
SYN|ACK didn't update the rtt estimate or if it did, didn't so so very 
much.  Bug? Feature?  No idea, but food for thought.

rick jones
