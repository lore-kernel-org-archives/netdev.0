From: "xerces8" <xerces8@butn.net>
Subject: Different routing for one process ?
Date: Tue, 06 Mar 2007 14:55:38 +0100
Message-ID: <WorldClient-F200703061455.AA55380210@butn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ikar.perftech.si ([195.246.0.20]:41315 "EHLO ikar.perftech.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965043AbXCFOOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 09:14:15 -0500
Received: from dedal.perftech.si (unknown [10.12.0.44])
	by ikar.perftech.si (Spam Firewall) with ESMTP id 8489A56BCA
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2007 14:55:43 +0100 (CET)
Received: from WorldClient by butn.net
	(MDaemon PRO v9.5.4)
	with ESMTP id 41-md50000231054.msg
	for <netdev@vger.kernel.org>; Tue, 06 Mar 2007 14:55:40 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(another repost from linux-net)

Hi!
 
Is there a way to make one process route differently than the rest of the system ?
 
My situation is this: I have a PC on a very restrictive network ((P)NAT&filtering). I want to
run an application that is more or less a SIP telephone client. SIP is of course blocked on
the network. The only option I see is a tunnel to a friendlier place on the net and route
the SIP traffic over it. This I already did using OpenVPN. The problem is, that I want to
the tunnel to be used for SIP only and not toehr net access (due to limited bandwith of
the tunnel and other reasons).
 
My current solution is to run the SIP application inside a VMWare virtual machine, that does
all it's networking over the tunnel.
 
I wonder if I can do it without running vmware, since that seems like shooting a sparrow with a cannon.
 
Note that the SIP client can communicate with the entire world, I can not predict who will call me
and from what IP address.
 
(I linger between linux and windows, so if someone knows a person or mail list with windows
network experts, that would be helpful too)
 
 
Regards,
David


