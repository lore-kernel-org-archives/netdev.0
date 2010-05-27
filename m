From: bengan@bag.org
Subject: ipsec and gre on the same interface
Date: Thu, 27 May 2010 11:28:57 +0200
Message-ID: <201005271128.57865.bengan@bag.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.bag.org ([194.68.48.90]:52234 "EHLO nic.bag.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978Ab0E0JjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 05:39:23 -0400
Received: from linux-do4z.localnet (235.211.216.81.static.ksn.siw.siwnet.net [81.216.211.235])
	by nic.bag.org (Postfix) with ESMTP id 34D7526C002
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 11:28:52 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got a set up with two boxes (routers) with ipsec and gre (quagga for the 
routing) that works but that includes 2 different interfaces in each box. But 
I would like to do this in a box with only one interface for ipsec and gre. Is 
that possible? In a vmware setup I have eth0 and eth1 as my two interfaces and 
established an endpoint for the gre tunnel in eth1 I can get ipsec and gre 
running and forwarding packets. But when I want to do the same thing with only 
one interface it doesn't work.

Am I doing something really stupid or should this work? If I'm doing something 
really stupid could you explain what?


The setup

Working setup

       ****          ****                                                 
       *  *----------*  *                                                 
       ****          ****                                                 
              ipsec                                                            
           <-------->                                                     

              gre 
       <----------------> 



The setup I would like to get working

       ****          ****                                                 
       *  *----------*  *                                                 
       ****          ****                                                 
              ipsec                                                            
           <-------->                                                     

              gre 
           <--------> 


regards,


/bengan
