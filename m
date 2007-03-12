From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 4/4] [TULIP] Rev tulip version
Date: Mon, 12 Mar 2007 12:44:12 +0200
Message-ID: <84144f020703120344n3f5ed52axf0bc1c109b549535@mail.gmail.com>
References: <20070312093128.577087000@linux.intel.com>
	 <20070312095912.743760000@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Jeff Garzik" <jeff@garzik.org>
To: "Valerie Henson" <val_henson@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:63811 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965511AbXCLKoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 06:44:14 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1964189nfa
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 03:44:13 -0700 (PDT)
In-Reply-To: <20070312095912.743760000@linux.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 3/12/07, Valerie Henson <val_henson@linux.intel.com> wrote:
> --- tulip-2.6-mm-linux.orig/drivers/net/tulip/tulip_core.c
> +++ tulip-2.6-mm-linux/drivers/net/tulip/tulip_core.c
> @@ -17,11 +17,11 @@
>
>  #define DRV_NAME       "tulip"
>  #ifdef CONFIG_TULIP_NAPI
> -#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
> +#define DRV_VERSION    "1.1.15-NAPI" /* Keep at least for test */
>  #else
> -#define DRV_VERSION    "1.1.14"
> +#define DRV_VERSION    "1.1.15"
>  #endif
> -#define DRV_RELDATE    "May 11, 2002"
> +#define DRV_RELDATE    "Feb 27, 2007"

Why not just drop this? What purpose does a per-module revision have
for in-kernel drivers anyway?

                                      Pekka
