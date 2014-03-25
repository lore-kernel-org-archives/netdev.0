From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net-next 4/7] qlcnic: Remove casts of pointer to same
 type
Date: Tue, 25 Mar 2014 05:50:38 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F809CB@avmb2.qlogic.org>
References: <cover.1395692043.git.joe@perches.com>
 <ac82455e9d2f0487a3f96c44a41b5557fd09af95.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ac82455e9d2f0487a3f96c44a41b5557fd09af95.1395692043.git.joe@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Tuesday, March 25, 2014 1:46 AM
> To: netdev
> Cc: Shahed Shaikh; Dept-HSG Linux NIC Dev; linux-kernel
> Subject: [PATCH net-next 4/7] qlcnic: Remove casts of pointer to same type
> 
> Casting a pointer to a pointer of the same type is pointless, so remove these
> unnecessary casts.
> 
> Done via coccinelle script:
> 
> $ cat typecast_2.cocci
> @@
> type T;
> T *foo;
> @@
> 
> -	(T *)foo
> +	foo
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Thanks,
Shahed
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
> index ec399b7..2d91975 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
> @@ -1388,7 +1388,7 @@ static int qlcnic_83xx_copy_fw_file(struct
> qlcnic_adapter *adapter)
>  	addr = (u64)dest;
> 
>  	ret = qlcnic_83xx_ms_mem_write128(adapter, addr,
> -					  (u32 *)p_cache, size / 16);
> +					  p_cache, size / 16);
>  	if (ret) {
>  		dev_err(&adapter->pdev->dev, "MS memory write
> failed\n");
>  		release_firmware(fw);
> --
> 1.8.1.2.459.gbcd45b4.dirty
