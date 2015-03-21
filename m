From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces
 with "ktime_t" type
Date: Sat, 21 Mar 2015 10:21:59 +0100
Message-ID: <20150321092159.GA27489@localhost.localdomain>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
 <CAMz4kuKyDFCqd-LfoSKJf+tkXdzzLwtPJdp-nF6NbKU8W5HHpQ@mail.gmail.com>
 <20150320062603.GC4417@localhost.localdomain>
 <201503201443.42672.arnd@linaro.org>
 <20150320164951.GA25334@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baolin Wang <baolin.wang@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.com>,
	tglx@linutronix.de
To: Arnd Bergmann <arnd@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150320164951.GA25334@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 20, 2015 at 05:49:51PM +0100, Richard Cochran wrote:
> There is really no need for any dancing around here.  There are
> seventeen users total.
> 
>   drivers/net/ethernet/adi/bfin_mac.c
>   drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
>   drivers/net/ethernet/broadcom/tg3.h
>   drivers/net/ethernet/freescale/fec_ptp.c
>   drivers/net/ethernet/freescale/gianfar_ptp.c
>   drivers/net/ethernet/intel/e1000e/ptp.c
>   drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
>   drivers/net/ethernet/intel/i40e/i40e_ptp.c
>   drivers/net/ethernet/intel/igb/igb_ptp.c
>   drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
>   drivers/net/ethernet/mellanox/mlx4/en_clock.c
>   drivers/net/ethernet/sfc/ptp.c
>   drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
>   drivers/net/ethernet/ti/cpts.c
>   drivers/net/ethernet/tile/tilegx.c
>   drivers/net/phy/dp83640.c

And with these two,

    drivers/ptp/ptp_ixp46x.c
    drivers/ptp/ptp_pch.c

there are nineteen total.

Thanks,
Richard
