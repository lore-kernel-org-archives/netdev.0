From: Erik Schweigert <ejschweigert@gmail.com>
Subject: Ethernet bridge not passing VLAN'd traffic
Date: Tue, 19 Oct 2010 16:24:05 -0700
Message-ID: <AANLkTi=RLjMq5im69dDqu133t-GYSMMymhJFAkfrs+i=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:53613 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454Ab0JSXYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 19:24:07 -0400
Received: by gwb10 with SMTP id 10so34091gwb.19
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 16:24:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello list,

I have configured a transparent ethernet bridge containing two network
interfaces: eth0, eth1 in br0.  IP forwarding is enabled i.e. cat
/proc/sys/net/ipv4/ip_forward = 1.

All traffic destined through my Linux machine has the 802.1Q tag
(VLAN).  However, only ARP with the VLAN tags passes through the
machine correctly (100% of the time) and broadcast and multicast
appears to work.  It 'seems' IP layer and above is being dropped if it
is unicast, or intermittently works ( +/- 1 of 10 ICMP passes
through).

All non-VLAN'd traffic passes through my machine flawlessly.

arptables, ebtables, and IPtables are all flushed, so there is no
possibility of any traffic being blocked.

Is there a caveat with ethernet bridging that does not permit VLAN'd traffic?

Any help or suggestions is greatly appreciated!

Thanks,

Erik
