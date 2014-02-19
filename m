From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] atm: ambassador: use NULL instead of 0 for pointer
Date: Wed, 19 Feb 2014 09:52:55 -0500
Message-ID: <20140219095255.1c1684b2@thirdoffive.cmf.nrl.navy.mil>
References: <4982315.WAlBt88ElR@daeseok-laptop.cloud.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daeseok Youn <daeseok.youn@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4982315.WAlBt88ElR@daeseok-laptop.cloud.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Feb 2014 14:11:15 +0900
Daeseok Youn <daeseok.youn@gmail.com> wrote:

> >From 932e928d53b1e588dc17019e7f9fa7a61b8b7468 Mon Sep 17 00:00:00 2001
> From: Daeseok Youn <daeseok.youn@gmail.com>
> Date: Wed, 19 Feb 2014 10:35:41 +0900
> Subject: [PATCH] atm: ambassador: use NULL instead of 0 for pointer
> 
> sparse says:
> 
> drivers/atm/ambassador.c:1928:24: warning:
>  Using plain integer as NULL pointer
> 
> Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>
> ---
>  drivers/atm/ambassador.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
> index 62a7607..f1a9198 100644
> --- a/drivers/atm/ambassador.c
> +++ b/drivers/atm/ambassador.c
> @@ -1925,7 +1925,7 @@ static int ucode_init(loader_block *lb, amb_dev *dev)
>    const struct firmware *fw;
>    unsigned long start_address;
>    const struct ihex_binrec *rec;
> -  const char *errmsg = 0;
> +  const char *errmsg = NULL;
>    int res;
>  
>    res = request_ihex_firmware(&fw, "atmsar11.fw", &dev->pci_dev->dev);

Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
