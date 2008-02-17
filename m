From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATHCH 0/16]  ServerEngines 10Gb NIC driver
Date: Sat, 16 Feb 2008 19:51:13 -0800
Message-ID: <20080217035113.d5342ffc@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.242.147]:18029 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbYBQDvQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 22:51:16 -0500
Received: from 59.93.89.51 ([59.93.89.51])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Sat, 16 Feb 2008 19:51:13 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 0/16 and 15/16 of this series are getting dropped by the
spam filter.  I am trying to get them across with changes
that will please the spam filter.  Sorry about the inconvenience.
Below is the 0/16 of the series.

--------------------------
Hi,


I am sending a patch for network driver for ServerEngines 10Gb Network adapter for review.  This patch includes the network driver and the OS neutral code that implements the interactions between the host drivers and the adapter. The adapter is a dual function device with network and storage functions.  The network driver is a regular NIC driver.  

The low level library that manages the interaction with the adapter is common to both storage and network drivers and hence is organized under the directory drivers/message/beclib. The storage driver is not part of this patch and will be submitted after this review.

This patch is made against 2.6.24.2 version of the kernel source.

Thank you.

Subbu Seetharaman

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>

------------------------

drivers/net/benet/be.h	                                            373
drivers/net/benet/bni.h	                                            374
drivers/net/benet/be_init.c                                        1426
drivers/net/benet/be_netif.c                                        600
drivers/net/benet/be_int.c                                         1254
drivers/net/benet/be_tx.c                                           191
drivers/net/benet/bni.c                                            1506
drivers/net/benet/be_ethtool.c                                      410
drivers/net/benet/be_proc.c                                         679
drivers/net/benet/Makefile                                           25
drivers/net/Kconfig                                                  15
drivers/net/Makefile                                                  1
MAINTAINERS                                                           6
drivers/message/beclib/pch.h                                         58
drivers/message/beclib/beclib_common.h                              111
drivers/message/beclib/beclib_ll.h                                  682
drivers/message/beclib/beclib_private_ll.h                          451
drivers/message/beclib/beclib_stats.h                                73
drivers/message/beclib/beclib_ll_enum_nic.h                          68
drivers/message/beclib/beclib_ll_bmap_nic.h                        1720
drivers/message/beclib/bestatus.h                                   129
drivers/message/beclib/beregister.h                                 366
drivers/message/beclib/main_ll.c                                     53
drivers/message/beclib/chipobj_ll.c                                 145
drivers/message/beclib/funcobj_ll.c                                2339
drivers/message/beclib/ethtx_ll.c                                    61
drivers/message/beclib/ethrx_ll.c                                   430
drivers/message/beclib/rxf_ll.c                                    1008
drivers/message/beclib/eq_ll.c                                      751
drivers/message/beclib/cq_ll.c                                      443
drivers/message/beclib/mpu_ll.c                                    1559
drivers/message/beclib/sa/setypes.h                                  70
drivers/message/beclib/sa/sa.c                                      278
drivers/message/beclib/sa/sa.h                                     1004
drivers/message/beclib/fw/amap/ioctl_opcodes.h                      812
drivers/message/beclib/fw/amap/ioctl_defs.h                         115
drivers/message/beclib/fw/amap/host_struct.h                        115
drivers/message/beclib/fw/amap/be_common.h                           86
drivers/message/beclib/fw/amap/ep.h                                  99
drivers/message/beclib/fw/amap/descriptors.h                        105
drivers/message/beclib/fw/amap/be_cm.h                              110
drivers/message/beclib/fw/amap/headers.h                             84
drivers/message/beclib/fw/amap/ioctl_top.h                           63
drivers/message/beclib/fw/amap/ioctl_types.h                        459
drivers/message/beclib/fw/amap/ioctl_common.h                       260
drivers/message/beclib/fw/amap/mpu_context.h                         56
drivers/message/beclib/fw/amap/ioctl_eth.h                           95
drivers/message/beclib/fw/amap/etx_context.h                         87
drivers/message/beclib/fw/amap/cev.h                                275
drivers/message/beclib/fw/amap/asyncmesg.h                           98
drivers/message/beclib/fw/amap/mpu.h                                107
drivers/message/beclib/fw/amap/doorbells.h                          211
drivers/message/beclib/fw/amap/ioctl_mcc.h                          128
drivers/message/beclib/fw/amap/ioctl_hdr.h                           58
drivers/message/beclib/fw/amap/regmap.h                             100
drivers/message/beclib/fw/amap/common_context.h                      73
drivers/message/beclib/fw/amap/post_codes.h                         127
drivers/message/beclib/fw/be_gen_id_ranges.h                        240
drivers/message/beclib/fw/bmap/ioctl_types_bmap.h                   521
drivers/message/beclib/fw/bmap/etx_context_bmap.h                   118
drivers/message/beclib/fw/bmap/host_struct_bmap.h                   254
drivers/message/beclib/fw/bmap/doorbells_bmap.h                     470
drivers/message/beclib/fw/bmap/mpu_bmap.h                           155
drivers/message/beclib/fw/bmap/asyncmesg_bmap.h                     158
drivers/message/beclib/fw/bmap/be_common_bmap.h                     150
drivers/message/beclib/fw/bmap/ioctl_common_bmap.h                 1398
drivers/message/beclib/fw/bmap/ep_bmap.h                            175
drivers/message/beclib/fw/bmap/cev_bmap.h                           552
drivers/message/beclib/fw/bmap/be_cm_bmap.h                         174
drivers/message/beclib/fw/bmap/iscsi_initiator_host_struct_bmap.h   642
drivers/message/beclib/fw/bmap/descriptors_bmap.h                   124
drivers/message/beclib/fw/bmap/regmap_bmap.h                        204
drivers/message/beclib/fw/bmap/ioctl_hdr_bmap.h                      87
drivers/message/beclib/fw/bmap/ioctl_top_bmap.h                      61
drivers/message/beclib/fw/bmap/pcicfg_bmap.h                       2333
drivers/message/beclib/fw/bmap/iscsi_common_host_struct_bmap.h      406
drivers/message/beclib/fw/bmap/mpu_context_bmap.h                   102
drivers/message/beclib/fw/bmap/ioctl_eth_bmap.h                     378
drivers/message/beclib/fw/bmap/ioctl_mcc_bmap.h                     113
drivers/message/beclib/fw/bmap/post_codes_bmap.h                    101

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

