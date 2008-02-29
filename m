From: Pavel Krauz <krauz@cncz.cz>
Subject: Re: capturing VLAN
Date: Fri, 29 Feb 2008 16:45:20 +0100
Message-ID: <200802291645.21331.krauz@cncz.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kwall.cncz.cz ([194.213.192.9]:28206 "EHLO kwall.cncz.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754530AbYB2Ppb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 10:45:31 -0500
Received: from asterix.domain.local (unknown [10.3.1.3])
	by kwall.cncz.cz (Postfix) with ESMTP id C0984BAB35
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 16:45:30 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Hi guys
>> as I see it, capturing packets with VLAN tag over PCAP is simply
>> broken on 2.6 kernel with the HW acceleration. Applications that need
>> unmodified packets over PCAP in promisc mode cannot work when VLAN
>> is present in the traffic.

> Older kernels (e.g. debian 2.6.18) had the problem that when you enable
> 802.1q VLAN support the acenic driver dropped the first vlan tag on a
> packet regardless if you enable vlans or not. If you recompile a kernel
> without 802.1q VLAN support all 802.1q tags should be in the pcap.

Unfortunately even when the CONFIG_VLAN_8021Q is undefined (no 
support for VLAN in kernel) I do not get the VLAN tags in PCAP for
NetXtreme II driver (I do not know about the Intel E1000 driver
which we also use). Even if it worked I do not think it solves the problem
-  you may need to connect the server over VLAN on different
(non monitoring) eth interface.

b.r.
Pavel
