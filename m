From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: correctly handle qlcnic_alloc_mbx_args
Date: Tue, 29 Dec 2015 14:46:15 -0500 (EST)
Message-ID: <20151229.144615.1025537000748350969.davem@davemloft.net>
References: <1451417387-11321-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451417387-11321-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Tue, 29 Dec 2015 14:29:47 -0500

> Signed-off-by: Insu Yun <wuninsu@gmail.com>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
> index a5f422f..a9a2c33 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
> @@ -772,8 +772,10 @@ int qlcnic_82xx_config_intrpt(struct qlcnic_adapter *adapter, u8 op_type)
>  	int i, err = 0;
>  
>  	for (i = 0; i < ahw->num_msix; i++) {
> -		qlcnic_alloc_mbx_args(&cmd, adapter,
> +		err = qlcnic_alloc_mbx_args(&cmd, adapter,
>  				      QLCNIC_CMD_MQ_TX_CONFIG_INTR);

You must fix the indentation of the second line of the function call when
you made changes like this.  The first character on the second line of the
call must be exactly at the first column after the openning parenthesis of
the first line.

You must must the appropriate number of TAB and then SPACE characters
necessary to achieve this.

Thanks.
