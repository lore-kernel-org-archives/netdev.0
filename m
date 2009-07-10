From: Tim Schneider <schneid5@cs.uni-bonn.de>
Subject: Using Wireless Extensions in a Kernel Module
Date: Fri, 10 Jul 2009 11:23:22 +0200
Message-ID: <A353FA76-7D71-425F-BD67-FEE6DC26EF6F@cs.uni-bonn.de>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix.iai.uni-bonn.de ([131.220.8.4]:51019 "EHLO
	postfix.iai.uni-bonn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbZGJJXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 05:23:25 -0400
Received: from [10.0.1.10] (dslb-084-063-085-116.pools.arcor-ip.net [84.63.85.116])
	by postfix.iai.uni-bonn.de (Postfix) with ESMTP id 542705C839
	for <netdev@vger.kernel.org>; Fri, 10 Jul 2009 11:23:23 +0200 (MEST)
	(envelope-from schneid5@cs.uni-bonn.de)
	(envelope-to netdev@vger.kernel.org) (1)
	(internal use: ta=1, tu=1, te=1, am=P, au=schneid5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to write a Kernel Module with an implementation of a new  
TCP-Algorithm. Since I need to know the RSSI-Value (Received Signal  
Strength indication) of the sent package, I extended the Pluggable  
Congestion Control Mechanism by a new function which is called right  
after the package is send. At that point, I need to read the RSSI-Value.

I'm now trying to somehow access that value, but I can't figure out  
how. I've come as far, that I found out about the Wirelless  
Extensions, which seem to be very promising. In the header file the  
author states, that this mechanism can be used by both user-space apps  
and kernel modules. Unfortunately nobody seems to ever have used it in  
kernel space, since I can't find any documentations about it.

I would be very glad, if somebody could give me link to a page  
containing informations about this topic, or even just a hint that  
could help me.

Thank you

Tim Schneider

