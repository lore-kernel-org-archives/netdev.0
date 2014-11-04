From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V1 net-next 5/5] net/mlx4_core: Add retrieval of
 CONFIG_DEV parameters
Date: Tue, 04 Nov 2014 08:48:34 -0800
Message-ID: <1415119714.1005.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>
	 <1414938377-421-6-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36974 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbaKDQsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 11:48:36 -0500
Received: by mail-ie0-f174.google.com with SMTP id x19so7905281ier.33
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 08:48:36 -0800 (PST)
In-Reply-To: <1414938377-421-6-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-02 at 16:26 +0200, Or Gerlitz wrote:
> From: Matan Barak <matanb@mellanox.com>
> 
> Add code to issue CONFIG_DEV "get" firmware command.
> 
> This command is used in order to obtain certain parameters used for
> supporting various RX checksumming options and vxlan UDP port.
> 
> The GET operation is allowed for VFs too.
> 
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Shani Michaeli <shanim@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cmd.c           |    4 +-
>  drivers/net/ethernet/mellanox/mlx4/fw.c            |   88 +++++++++++++++++++-
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    5 +
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   17 ++++
>  include/linux/mlx4/cmd.h                           |   29 +++++++
>  include/linux/mlx4/device.h                        |    3 +-
>  6 files changed, 139 insertions(+), 7 deletions(-)

This added following warnings :

  CC      drivers/net/ethernet/mellanox/mlx4/fw.o
drivers/net/ethernet/mellanox/mlx4/fw.c: In function 'mlx4_config_dev_retrieval':
drivers/net/ethernet/mellanox/mlx4/fw.c:1944:12: warning: 'config_dev.rx_checksum_val' may be used uninitialized in this function [-Wmaybe-uninitialized]
In file included from include/linux/swab.h:4:0,
                 from include/uapi/linux/byteorder/little_endian.h:12,
                 from include/linux/byteorder/little_endian.h:4,
                 from ./arch/x86/include/uapi/asm/byteorder.h:4,
                 from include/asm-generic/bitops/le.h:5,
                 from ./arch/x86/include/asm/bitops.h:504,
                 from include/linux/bitops.h:33,
                 from include/linux/kernel.h:10,
                 from include/linux/skbuff.h:17,
                 from include/linux/if_ether.h:23,
                 from include/linux/etherdevice.h:25,
                 from drivers/net/ethernet/mellanox/mlx4/fw.c:35:
include/uapi/linux/swab.h:53:93: warning: 'config_dev.vxlan_udp_dport' may be used uninitialized in this function [-Wmaybe-uninitialized]
drivers/net/ethernet/mellanox/mlx4/fw.c:1922:25: note: 'config_dev.vxlan_udp_dport' was declared here
