From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe and mac-vlans problem
Date: Thu, 06 May 2010 13:49:14 -0700
Message-ID: <4BE32B4A.2030409@candelatech.com>
References: <4BDA07DB.8020206@candelatech.com> <201004302000.58763.arnd@arndb.de> <4BDB1CF3.8030906@candelatech.com> <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com> <4BDB57A6.1090400@candelatech.com> <EA929A9653AAE14F841771FB1DE5A1365FE5560B00@rrsmsx501.amr.corp.intel.com> <4BE2ECEE.7070200@candelatech.com> <EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, NetDev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35575 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932557Ab0EFUt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 16:49:26 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2010 10:51 AM, Tantilov, Emil S wrote:

> Hi Ben,
>
> We do have a patch in testing (see attached). It may not apply cleanly as it is on top of some other patches currently in validation. Let me know if it works for you.

It wasn't difficult to backport this patch to 2.6.31.12....

I just tested this on an 85998 NIC and 50 MAC-VLANs worked fine.

The NIC doesn't show as PROMISC in any way I can detect, but I guess
it must actually be in PROMISC mode:

[root@i7-1qc-1 ~]# cat /sys/class/net/eth11/flags
0x1003

[root@i7-1qc-1 ~]# ip link show dev eth11
2: eth11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
     link/ether 00:e0:ed:11:25:12 brd ff:ff:ff:ff:ff:ff

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

