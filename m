From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: please revert. Was: [for-next 4/6] net/mlx5: FPGA, Add basic support
 for Innova
Date: Thu, 25 May 2017 20:58:32 -0700
Message-ID: <20170526035830.mrnmxosh262bwjcr@ast-mbp>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32814 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965088AbdEZD6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 23:58:36 -0400
Content-Disposition: inline
In-Reply-To: <20170523114404.20387-5-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 02:44:02PM +0300, Saeed Mahameed wrote:
> From: Ilan Tayari <ilant@mellanox.com>
> 
> Mellanox Innova is a NIC with ConnectX and an FPGA on the same
> board. The FPGA is a bump-on-the-wire and thus affects operation of
> the mlx5_core driver on the ConnectX ASIC.
> 
> Add basic support for Innova in mlx5_core.
>
> This allows using the Innova card as a regular NIC, by detecting
> the FPGA capability bit, and verifying its load state before
> initializing ConnectX interfaces.
> 
> Also detect FPGA fatal runtime failures and enter error state if
> they ever happen.
> 
> All new FPGA-related logic is placed in its own subdirectory 'fpga',
> which may be built by selecting CONFIG_MLX5_FPGA.
> This prepares for further support of various Innova features in later
> patchsets.
> Additional details about hardware architecture will be provided as
> more features get submitted.
> 
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>
> Reviewed-by: Boris Pismenny <borisp@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  MAINTAINERS                                        |  10 +
>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |  10 +
>  drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  11 ++
>  drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c |  64 +++++++
>  drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h |  59 ++++++
>  .../net/ethernet/mellanox/mlx5/core/fpga/core.c    | 202 +++++++++++++++++++++
>  .../net/ethernet/mellanox/mlx5/core/fpga/core.h    |  99 ++++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/main.c     |  19 +-
>  include/linux/mlx5/device.h                        |   6 +
>  include/linux/mlx5/driver.h                        |   5 +
>  include/linux/mlx5/mlx5_ifc.h                      |  11 +-
>  include/linux/mlx5/mlx5_ifc_fpga.h                 | 144 +++++++++++++++
>  13 files changed, 640 insertions(+), 3 deletions(-)

Dave, please revert this Innova fpga stuff.
I think you pushed it by accident, since it was mixed with
other valid changes.
The discussion didn't conclude.
Myself and Jes are clearly against such changes.
It definitely needs more discussion and wider consensus.

Thanks
