From: Karl Hiramoto <karl@hiramoto.org>
Subject: loosing connections on bridge topology changes
Date: Wed, 13 May 2009 17:13:41 +0200
Message-ID: <4A0AE3A5.20100@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:39366 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241AbZEMPO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 11:14:59 -0400
Received: from spunkymail-a5.g.dreamhost.com (caiajhbdcaid.dreamhost.com [208.97.132.83])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 0956F179F76
	for <netdev@vger.kernel.org>; Wed, 13 May 2009 08:14:52 -0700 (PDT)
Received: from [192.168.10.51] (81.Red-83-44-145.dynamicIP.rima-tde.net [83.44.145.81])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by spunkymail-a5.g.dreamhost.com (Postfix) with ESMTP id 51E3D20C1C
	for <netdev@vger.kernel.org>; Wed, 13 May 2009 08:13:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I have a user space application, that puts eth0 into bridge br0.  At 
this moment all connections seem frozen. Telnet, HTTP, and NFS.

For development i have nfs root fs.

There is a ioctl() that does the equivalent of "brctl addif br0 eth0"

That cuts all the connections for a few seconds.

nfs: server 192.168.10.51 not responding, still trying
br0: topology change detected, propagating           
br0: port 1(eth0) entering forwarding state          
nfs: server 192.168.10.51 not responding, still trying
nfs: server 192.168.10.51 OK                         
nfs: server 192.168.10.51 OK  


Then everything is OK..

Is there anyway i can fix this, so my applicaion goes ahead at full speed?


using libnl i tried flushing the ARP cache on all devices, but it didn't 
seem to help.


Thanks
--

Karl.

