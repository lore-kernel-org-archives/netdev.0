From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Compile-time warnings on mlx4/net-next
Date: Thu, 15 Jan 2015 11:05:27 -0200
Message-ID: <54B7BB17.8090308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752419AbbAONFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 08:05:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Or,

Building net-next.git from today, 4e7a84b1a5bc8094522fd11f628b00c4b4e78=
b4d,
I'm seeing these warnings on mlx4:

drivers/net/ethernet/mellanox/mlx4/fw.c: In function =91mlx4_config_dev=
_retrieval=92:
drivers/net/ethernet/mellanox/mlx4/fw.c:2136:12: warning: =91config_dev=
=2Erx_checksum_val=92 may be used uninitialized in this function [-Wmay=
be-uninitialized]
  csum_mask =3D (config_dev.rx_checksum_val >> CONFIG_DEV_RX_CSUM_MODE_=
PORT2_BIT_OFFSET) &
            ^
In file included from include/linux/swab.h:4:0,
                 from include/uapi/linux/byteorder/little_endian.h:12,
                 from include/linux/byteorder/little_endian.h:4,
                 from ./arch/x86/include/uapi/asm/byteorder.h:4,
                 from include/asm-generic/bitops/le.h:5,
                 from ./arch/x86/include/asm/bitops.h:504,
                 from include/linux/bitops.h:36,
                 from include/linux/kernel.h:10,
                 from include/linux/skbuff.h:17,
                 from include/linux/if_ether.h:23,
                 from include/linux/etherdevice.h:25,
                 from drivers/net/ethernet/mellanox/mlx4/fw.c:35:
include/uapi/linux/swab.h:106:23: warning: =91config_dev.vxlan_udp_dpor=
t=92 may be used uninitialized in this function [-Wmaybe-uninitialized]
  (__builtin_constant_p((__u16)(x)) ? \
                       ^
drivers/net/ethernet/mellanox/mlx4/fw.c:2114:25: note: =91config_dev.vx=
lan_udp_dport=92 was declared here
  struct mlx4_config_dev config_dev;
                         ^

Do you see them too?=20

  Marcelo
