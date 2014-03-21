From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v3 4/9] ptp: drivers: set the number of
 programmable pins.
Date: Fri, 21 Mar 2014 01:02:06 -0700
Message-ID: <CAL3LdT6aZYiyebbN_e0LkPP8jQpO=5d=OCb9i2cKcdej6jPYcA@mail.gmail.com>
References: <cover.1395350105.git.richardcochran@gmail.com>
	<daae779db6ec1b3177c88024216f37d88fd59cd9.1395350113.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Christian Riesch <christian.riesch@omicron.at>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Stefan_S=C3=B8rensen?= <stefan.sorensen@spectralink.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <daae779db6ec1b3177c88024216f37d88fd59cd9.1395350113.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2014 at 2:21 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> This patch updates the many PTP Hardware Clock drivers with the
> newly introduced field that advertises the number of programmable
> pins. Some of these devices do have programmable pins, but the
> implementation will have to wait for follow on patches.
>
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/adi/bfin_mac.c              |    1 +
>  drivers/net/ethernet/broadcom/tg3.c              |    1 +
>  drivers/net/ethernet/freescale/fec_ptp.c         |    1 +
>  drivers/net/ethernet/freescale/gianfar_ptp.c     |    1 +
>  drivers/net/ethernet/intel/e1000e/ptp.c          |    1 +
>  drivers/net/ethernet/mellanox/mlx4/en_clock.c    |    1 +
>  drivers/net/ethernet/sfc/ptp.c                   |    1 +
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c |    1 +
>  drivers/net/ethernet/ti/cpts.c                   |    1 +
>  drivers/net/ethernet/tile/tilegx.c               |    1 +
>  drivers/ptp/ptp_ixp46x.c                         |    1 +
>  drivers/ptp/ptp_pch.c                            |    1 +
>  12 files changed, 12 insertions(+)
>

For the e1000e change...

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
