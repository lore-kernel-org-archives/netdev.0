From: "Nobuhiro Iwamatsu" <iwamatsu@nigauri.org>
Subject: Re: [PATCH] sh_eth Add SH7619 support
Date: Fri, 1 Aug 2008 12:48:27 +0900
Message-ID: <29ab51dc0807312048hfa9cd88pb90d1a7520bb3f99@mail.gmail.com>
References: <878wvhtynu.wl%ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Nobuhiro Iwamatsu" <iwamatsu.nobuhiro@renesas.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: "Yoshinori Sato" <ysato@users.sourceforge.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:40835 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbYHADs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 23:48:28 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1165486wfd.4
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 20:48:27 -0700 (PDT)
In-Reply-To: <878wvhtynu.wl%ysato@users.sourceforge.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Sato-san.

2008/8/1 Yoshinori Sato <ysato@users.sourceforge.jp>:
> SH7619 have same SH7710 ethernet controler.
> Add support for sh_eth driver.
>
> Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
>

<snip>

>
> diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
> index 45ad1b0..ca3cc5f 100644
> --- a/drivers/net/sh_eth.h
> +++ b/drivers/net/sh_eth.h
> @@ -143,10 +143,11 @@
>

<snip>

> +
> +/* CPU endian from/to EDMAC endian */
> +#if !defined(CONFIG_CPU_SUBTYPE_SH7619)
> +#define cpu_to_edmac(x) cpu_to_le32(x)
> +#define edmac_to_cpu(x) le32_to_cpu(x)
> +#else
> +#define cpu_to_edmac(x) cpu_to_be32(x)
> +#define edmac_to_cpu(x) be32_to_cpu(x)
> +#endif
> +
>  #endif
I think that this depends on an endian not CPU dependence.

Best regards,
 Nobuhiro
