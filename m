From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH] fjes: fix inconsistent indenting
Date: Thu, 12 Nov 2015 03:38:48 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A54285D79@G01JPEXMBYT01>
References: <1447255360-31468-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Markus Elfring <elfring@users.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447255360-31468-1-git-send-email-colin.king@canonical.com>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, Colin.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

> -----Original Message-----
> From: Colin King [mailto:colin.king@canonical.com]
> Sent: Thursday, November 12, 2015 12:23 AM
> To: David S. Miller; Izumi, Taku/泉 拓; Markus Elfring; netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Subject: [PATCH] fjes: fix inconsistent indenting
> 
> From: Colin Ian King <colin.king@canonical.com>
> 
> minor change, indenting is one tab out.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/fjes/fjes_hw.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
> index bb8b530..b103adb 100644
> --- a/drivers/net/fjes/fjes_hw.c
> +++ b/drivers/net/fjes/fjes_hw.c
> @@ -599,7 +599,7 @@ int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
>  		FJES_CMD_REQ_RES_CODE_BUSY) &&
>  	       (timeout > 0)) {
>  		msleep(200 + hw->my_epid * 20);
> -			timeout -= (200 + hw->my_epid * 20);
> +		timeout -= (200 + hw->my_epid * 20);
> 
>  		res_buf->unshare_buffer.length = 0;
>  		res_buf->unshare_buffer.code = 0;
> --
> 2.5.0
