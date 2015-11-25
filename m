From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: Re: [PATCH] ixp4xx_hss: Delete an unnecessary check before the function call "dma_pool_destroy"
Date: Wed, 25 Nov 2015 13:19:45 +0100
Message-ID: <m3lh9mz2xq.fsf@t19.piap.pl>
References: <5307CAA2.8060406@users.sourceforge.net>
	<alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	<530A086E.8010901@users.sourceforge.net>
	<alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	<530A72AA.3000601@users.sourceforge.net>
	<alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	<530B5FB6.6010207@users.sourceforge.net>
	<alpine.DEB.2.10.1402241710370.2074@hadrien>
	<530C5E18.1020800@users.sourceforge.net>
	<alpine.DEB.2.10.1402251014170.2080@hadrien>
	<530CD2C4.4050903@users.sourceforge.net>
	<alpine.DEB.2.10.1402251840450.7035@hadrien>
	<530CF8FF.8080600@users.sourceforge.net>
	<alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<5649CDD1.6050600@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5649CDD1.6050600@users.sourceforge.net> (SF Markus Elfring's
	message of "Mon, 16 Nov 2015 13:36:33 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SF Markus Elfring <elfring@users.sourceforge.net> writes:

> The dma_pool_destroy() function tests whether its argument is NULL
> and then returns immediately. Thus the test around the call is not needed.
>
> This issue was detected by using the Coccinelle software.

> --- a/drivers/net/wan/ixp4xx_hss.c
> +++ b/drivers/net/wan/ixp4xx_hss.c
> @@ -1037,7 +1037,7 @@ static void destroy_hdlc_queues(struct port *port)
>  		port->desc_tab = NULL;
>  	}
>  
> -	if (!ports_open && dma_pool) {
> +	if (!ports_open) {
>  		dma_pool_destroy(dma_pool);
>  		dma_pool = NULL;
>  	}

Acked-by: Krzysztof Halasa <khalasa@piap.pl>
-- 
Krzysztof Halasa

Industrial Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland
