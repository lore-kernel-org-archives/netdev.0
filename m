From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: query: ethtool --show-nfc mask interpretation
Date: Fri, 4 Jul 2014 21:43:12 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1407042034540.7230@ws.cisco>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:57252 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbaGDQNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 12:13:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was working on ethtool --show-nfc implementation for enic.

While displaying, ethtool displays the 1's compliment of
ethtool_rx_flow_spec->m_u.tcp_ip4_spec.psrc

I could not understand how to interpret the mask output

For eg.
[root@a163 linux-next]# ethtool -n enp9s0
8 RX rings available
Total 2 rules

Filter: 0
         Rule Type: TCP over IPv4
         Src IP addr: 10.65.79.1 mask: 255.255.0.0
         Dest IP addr: 10.106.186.163 mask: 255.255.255.255
         TOS: 0x0 mask: 0x0
         Src port: 51331 mask: 0xff
         Dest port: 22 mask: 0xffff
         Action: Direct to queue 4


The mask for src port is 0x00ff. Does that mean 8 bits in lsb should match and
the other 8 bits in msb should be ignored? Or is it the other way?

Thanks
