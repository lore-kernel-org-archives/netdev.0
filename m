From: Ben Greear <greearb@candelatech.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Wed, 23 Sep 2009 14:37:13 -0700
Message-ID: <4ABA9509.7000008@candelatech.com>
References: <4ABA4F8B.6040504@candelatech.com> <1253730766.2538.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36959 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbZIWVhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 17:37:11 -0400
In-Reply-To: <1253730766.2538.28.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I noticed that 'ethtool -d' has some counters that may be right,
including bytes.

(I'm looking at the 82599 chipset currently)

0x04074: gprc        (Good Packets Received Count)    0xF611E2C2
0x04078: bprc        (Broadcast Packets Rx Count)     0x00000000
0x0407C: mprc        (Multicast Packets Rx Count)     0x0000000C
0x04080: gptc        (Good Packets Transmitted Count) 0xC9962C10
0x04088: gorcl       (Good Octets Rx Count Low)       0x9A23F0B0
0x0408C: gorch       (Good Octets Rx Count High)      0x00000000
0x04090: gotcl       (Good Octets Tx Count Low)       0x5DFAACD4
0x04094: gotch       (Good Octets Tx Count High)      0x00000000


Any suggestions on a more efficient way to get these than dumping 'ethtool -d' and
searching all that data?  Maybe put it in 'ethtool -S' as well ?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

