From: Tim Schneider <schneid5@cs.uni-bonn.de>
Subject: Hopcount in Pluggable Congestion Avoidance Module
Date: Fri, 19 Jun 2009 10:51:59 +0200
Message-ID: <7F4E1ECF-94C4-4311-BEEE-CD5CA299B681@cs.uni-bonn.de>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix.iai.uni-bonn.de ([131.220.8.4]:48035 "EHLO
	postfix.iai.uni-bonn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbZFSJEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 05:04:47 -0400
Received: from [192.168.148.197] (unknown [131.220.243.209])
	by postfix.iai.uni-bonn.de (Postfix) with ESMTP id E77715C834
	for <netdev@vger.kernel.org>; Fri, 19 Jun 2009 10:52:07 +0200 (MEST)
	(envelope-from schneid5@cs.uni-bonn.de)
	(envelope-to netdev@vger.kernel.org) (1)
	(internal use: ta=1, tu=1, te=1, am=P, au=schneid5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

I am trying to implement a new congestion avoidance module which is  
optimized for multihop wireless networks. Since I'm new to kernel  
programming, it took me some time to find out about the pluggable  
congestion avoidance modules, which seem to be a really great and easy  
way to implement new algorithms. Unfortunately it is essential for me  
to have the hopcount of the TCP connection to implement the algorithm  
properly. As of now, I haven't found a way to get that Information out  
of the TCP-Socket. I also understand, that the TTL, which is, if I  
understand correctly, only available at the IP-Layer, does not provide  
reliable informations about the hopcount, since the TTL is set to 64  
as standard, but can be changed by anyone at will.
Are there any mechanisms to get the correct hopcount into my module?  
If not, is there a way to get the TTL of the ACK-Package, when it's  
received?

Thank you for your help.

Tim Schneider
