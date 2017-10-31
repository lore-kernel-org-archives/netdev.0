From: Ben Greear <greearb@candelatech.com>
Subject: fm10k cannot get link
Date: Tue, 31 Oct 2017 10:38:30 -0700
Message-ID: <430a2eb6-d378-34b7-a64a-585f1253e2b2@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:40498 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753885AbdJaRic (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:38:32 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id 532D840A339
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:38:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We're trying to get an Intel 100G NIC to work, and so far, cannot get it to link.

The cable is:  X0016I4AO3 QSFP28 10Gtek  (any suggestions for a better/different one?)

[    5.022681] fm10k 0000:05:00.0: PCI Express bandwidth of 64GT/s available
[    5.022683] fm10k 0000:05:00.0: (Speed:8.0GT/s, Width: x8, Encoding Loss:<2%, Payload:256B)
[    5.022684] fm10k 0000:05:00.0: 00:e0:ed:54:78:f2
[    5.027864] fm10k 0000:06:00.0: PCI Express bandwidth of 64GT/s available
[    5.027865] fm10k 0000:06:00.0: (Speed:8.0GT/s, Width: x8, Encoding Loss:<2%, Payload:256B)
[    5.027866] fm10k 0000:06:00.0: 00:e0:ed:54:78:f3
[    6.057950] Modules linked in: ioatdma(+) shpchp nfsd auth_rpcgss nfs_acl lockd grace sunrpc ast drm_kms_helper ttm igb drm i2c_algo_bit i2c_core ixgbe mdio 
hwmon fm10k ptp pps_core dca fjes ipv6 crc_ccitt
[    7.294441] fm10k 0000:05:00.0 eth0.r: renamed from eth0
[   14.044914] fm10k 0000:05:00.0 eth2: renamed from eth0.r
[   14.107798] fm10k 0000:06:00.0 eth1.r: renamed from eth1
[   14.178217] fm10k 0000:06:00.0 eth3: renamed from eth1.r


[root@lf1005c-is14120020 ~]# ethtool eth3
Settings for eth3:
	Current message level: 0x00000007 (7)
			       drv probe link
	Link detected: no


[root@lf1005c-is14120020 ~]# uname -a
Linux lf1005c-is14120020 4.9.29+ #46 SMP PREEMPT Wed Jul 26 17:48:57 PDT 2017 x86_64 x86_64 x86_64 GNU/Linux

[root@lf1005c-is14120020 ~]# ethtool -i eth3
driver: fm10k
version: 0.21.2-k
firmware-version:
bus-info: 0000:06:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: no

[root@lf1005c-is14120020 ~]# lspci|grep 06
06:00.0 Ethernet controller: Intel Corporation Device 15a4


Please let me know if you have any suggestions.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
