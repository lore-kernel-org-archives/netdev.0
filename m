From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: SMP Affinity and 3.12.7
Date: Mon, 10 Feb 2014 10:18:16 +0100
Message-ID: <8f0f9783b81bab41bc19c2cae8f4fec1@justnet.pl>
Reply-To: adam.niescierowicz@justnet.pl
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:56603 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbaBJJSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 04:18:17 -0500
Received: from [91.230.163.37] (helo=mail.justnet.pl)
	by service with esmtpa (Exim 4.72)
	(envelope-from <adam.niescierowicz@justnet.pl>)
	id 1WCn0K-0006gt-Uw
	for netdev@vger.kernel.org; Mon, 10 Feb 2014 10:18:17 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
i use 3.12.7 kernel when i set smp_affinity for network device kernel 
hangs.
SMP Affinity
---
             CPU0       CPU1       CPU2       CPU3       CPU4       CPU5  
      CPU6       CPU7
   67:        826        810    3962750    3962737        729        649  
       729        744   PCI-MSI-edge      eth1
   70:       4430       4476       4411       4431       4500       4466  
   3706636    3706649   PCI-MSI-edge      eth4

-- 

My network device
---
05:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit 
Ethernet Controller (Copper) (rev 01)
05:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit 
Ethernet Controller (Copper) (rev 01)
0a:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet 
Controller (Copper) (rev 06)
0a:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet 
Controller (Copper) (rev 06)
0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet 
Controller (Copper) (rev 06)
0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet 
Controller (Copper) (rev 06)
---

Can anyone help?


---
Thanks,
Adam N.
