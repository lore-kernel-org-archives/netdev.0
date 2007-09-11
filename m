From: DHAJOGLO <DHAJOGLO@smumn.edu>
Subject: noob dev question
Date: Mon, 10 Sep 2007 19:09:54 -0500
Message-ID: <200709110009540720c546a9@mail.smumn.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smumn.edu ([140.190.136.243]:4902 "EHLO mail.smumn.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756688AbXIKAP5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 20:15:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm new to the list and new to just about everything involving kernel development.  I'm working on a project where I have successfully written a LKM to handle IP packets for protocol type 253 (an experimental protocol number).  Now, I'm working on sending my reply and I hit a road block.  I'm not sure if I should:

1) create a new skb with my protocol data and try to pass it to the IP handler
OR
2) use the inbound skb and just turn it around and use it to send back out manually via a NF Hook.

Ideally I would like to get my reply formatted and sent into ip_queue_xmit but I'm at the limit of what I can do regarding the manipulation of the socket buffers.  I'm currently working in 2.6.18.8 as the book I'm using does not reflect some of the newer changes to the sk_buff struct.  Any help or pointers would be nice.  I'm looking more for online tutorials at this point.

Regards,
-dave



