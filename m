From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: [PATCH 2/2 v2] net: dsa: introduce MICREL KSZ8893MQL/BL ethernet
	switch chip support
Date: Wed, 21 Jul 2010 22:45:10 +0200
Message-ID: <AANLkTikTFOzykJCJCZvaeEEP7onCX4C_BAWVvdnh69o3@mail.gmail.com>
References: <1279719442-10174-2-git-send-email-vapier@gentoo.org>
	<1279729776-30091-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34566 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504Ab0GUUpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:45:13 -0400
Received: by wwj40 with SMTP id 40so2787403wwj.1
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 13:45:12 -0700 (PDT)
In-Reply-To: <1279729776-30091-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/10, Mike Frysinger <vapier@gentoo.org> wrote:
[...]
>  net/dsa/Kconfig    |    7 +
>  net/dsa/Makefile   |    1 +
>  net/dsa/ksz8893m.c |  341
> ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/dsa/ksz8893m.h |  163 +++++++++++++++++++++++++
>  4 files changed, 512 insertions(+), 0 deletions(-)
>  create mode 100644 net/dsa/ksz8893m.c
>  create mode 100644 net/dsa/ksz8893m.h
>
[...]
> +/* Port3Control0 defines */
> +#define TAG_INSERTION     0x04
> +
> +/* GlobalControl9 defines */
> +#define SPECIAL_TPID_MODE 0x01
> +

How about prefixes like 'PC0_' (PortControl0)  ?

-- 
Karl
