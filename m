From: Rick Jones <rick.jones2@hp.com>
Subject: DF, IP ID always 0 and the reassembly protections
Date: Tue, 20 Jun 2006 16:44:55 -0700
Message-ID: <44988877.2030205@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:28378 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1751865AbWFTXo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 19:44:56 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel13.hp.com (Postfix) with ESMTP id 37D6B3521C
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 16:44:56 -0700 (PDT)
Received: from hp.com (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id QAA14213
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 16:44:55 -0700 (PDT)
To: Linux Network Development list <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A while back (I cannot recall exactly when) the issue of always setting 
the IP datagram ID to zero when the DF bit was set was brought-up.  I 
suggested it might not be a good idea because there are admittedly 
broken devices out there that "helpfully" and silently clear DF and the 
start to fragment.  The counter point was that coding around such broken 
hardware was silly.

I was just writing a missive to one of my co-workers on IP 
fragmentation.  It got me to thinking about the stuff (I think it 
went-in?) to try to protect against "Frankengrams" during IP fragment 
reassembly.

Doesn't that mechanism rely on watching the IP ID's between the pair of 
IPs?  For both fragmented and non-fragmented datagrams? If so, does 
always setting the IP ID to zero when DF is set affect that mechanism?

rick jones
