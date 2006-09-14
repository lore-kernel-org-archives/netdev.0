From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Could not remove vlan with PPPoE sessions
Date: Thu, 14 Sep 2006 19:18:45 +0400
Message-ID: <20060914151845.GA13701@tentacle.sectorb.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <netdev-owner@vger.kernel.org>
Received: from tentacle.s2s.msu.ru ([193.232.119.109]:62874 "EHLO
	tentacle.sectorb.msk.ru") by vger.kernel.org with ESMTP
	id S1750759AbWINPSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 11:18:54 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

When using "vconfig rem" command to delete vlan device,
on which kernel-mode PPPoE session were active, vconfig
and all pppd processes froze in D state with all 
networking operation stuck, rendering the box non-functional.

Kernel started to print message:
 unregister_netdevice: waiting for vlan0154 to become free. Usage count = 3
in a loop until reboot.

This was kernel 2.6.18-rc7 on AMD64 box. It said 'Usage count = 3' and
there were exactly 3 pppd processes using vlan0154 interface and stuck
in D state.

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 

