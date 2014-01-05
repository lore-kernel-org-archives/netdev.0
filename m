From: Meelis Roos <mroos@linux.ee>
Subject: Cisco aironet 350 problem: Bad MAC enable reason=88, rid=ff10,
 offset=49392
Date: Mon, 6 Jan 2014 00:28:03 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1401060017390.28155@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Fabrice Bellet <fabrice@bellet.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.it.da.ut.ee ([193.40.5.66]:57611 "EHLO smtp1.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955AbaAEWud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 17:50:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried to make my X30 use wireless today and found that its 5.2.19 
firmware did not support WPA (scan results were fine). Put the card in 
another laptop with 
Windows, installed Cisco driver, that automatically upgraded the 
firmware to 5.60.21. Now the driver seems to think WPA is working. Scan 
results are also still there. But trying to enable the MAC on 
association gets an error like below (cmd 1 s MAC enable, 2 is MAC 
disable).

Googling around shows that people have had this problem already with 
5.41 firmware and I saw no solution to it. Are there any docs on 
firmware interfaces, or was it just reverse engineered - does anybody 
remmeber?


[    4.610572] airo(): Probing for PCI adapters
[    4.610881] airo(): Found an MPI350 card
[    5.579016] airo(eth1): Firmware version 5.60.21
[    5.579121] airo(eth1): WPA supported.
[    5.579191] airo(eth1): MAC enabled 00:02:8a:25:27:a8
[    5.581818] airo(): Finished probing for PCI adapters
[  110.237510] airo(eth1): link lost (local choice)
[  114.256285] airo(eth1): cmd:1 status:7f01 rsp0:88 rsp1:ff10 rsp2:c0f0
[  114.256302] airo(eth1): Bad MAC enable reason=88, rid=ff10, offset=49392
[  114.256357] airo(eth1): cmd:2 status:7f02 rsp0:0 rsp1:ff10 rsp2:c0f0
[  114.257493] airo(eth1): cmd:1 status:7f01 rsp0:88 rsp1:ff10 rsp2:c0f0
[  114.257502] airo(eth1): Bad MAC enable reason=88, rid=ff10, offset=49392
[  114.257727] airo(eth1): cmd:2 status:7f02 rsp0:0 rsp1:ff10 rsp2:c0f0
[  114.258856] airo(eth1): cmd:1 status:7f01 rsp0:88 rsp1:ff10 rsp2:c0f0
[  114.258866] airo(eth1): Bad MAC enable reason=88, rid=ff10, offset=49392
[  114.259957] airo(eth1): cmd:2 status:7f02 rsp0:0 rsp1:ff10 rsp2:c0f0
[  114.261153] airo(eth1): cmd:1 status:7f01 rsp0:88 rsp1:ff10 rsp2:c0f0
[  114.261164] airo(eth1): Bad MAC enable reason=88, rid=ff10, offset=49392
[  114.261226] airo(eth1): cmd:2 status:7f02 rsp0:0 rsp1:ff10 rsp2:c0f0
[  114.262232] airo(eth1): cmd:1 status:7f01 rsp0:88 rsp1:ff10 rsp2:c0f0
[  114.262241] airo(eth1): Bad MAC enable reason=88, rid=ff10, offset=49392
[  120.270865] airo(eth1): cmd:103 status:7f03 rsp0:0 rsp1:ff10 rsp2:c0f0
[  128.270296] airo(eth1): cmd:103 status:7f03 rsp0:0 rsp1:ff10 rsp2:c0f0
[  132.806204] airo(eth1): cmd:2 status:7f02 rsp0:0 rsp1:ff10 rsp2:c0f0
[  132.817940] airo(eth1): cmd:1 status:7f01 rsp0:88 rsp1:ff10 rsp2:c0f0
[  132.817959] airo(eth1): Bad MAC enable reason=88, rid=ff10, offset=49392
[  132.861628] airo(eth1): cmd:3 status:7f03 rsp0:0 rsp1:ff10 rsp2:c0f0
[  132.862728] airo(eth1): cmd:2 status:7f02 rsp0:0 rsp1:ff10 rsp2:c0f0
[  132.863799] airo(eth1): cmd:1 status:7f01 rsp0:88 rsp1:ff10 rsp2:c0f0
[  132.863809] airo(eth1): Bad MAC enable reason=88, rid=ff10, offset=49392
[  132.867607] airo(eth1): cmd:2 status:7f02 rsp0:0 rsp1:ff10 rsp2:c0f0

-- 
Meelis Roos (mroos@linux.ee)
