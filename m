From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net: add calxeda xgmac ethernet driver
Date: Fri, 4 Nov 2011 12:57:09 -0400
Message-ID: <CACxGe6sAFUwQc5Nk=gGLC+si-_C32AWu=E14vBkSm7YCFhazFg@mail.gmail.com>
References: <1319684206-473-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Rob Herring <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:58893 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932807Ab1KDQ5a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 12:57:30 -0400
Received: by qabj40 with SMTP id j40so2271270qab.19
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2011 09:57:30 -0700 (PDT)
In-Reply-To: <1319684206-473-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 10:56 PM, Rob Herring <robherring2@gmail.com> w=
rote:
> From: Rob Herring <rob.herring@calxeda.com>
>
> Add support for the XGMAC 10Gb ethernet device in the Calxeda Highban=
k
> SOC.
>
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>

Sinker question: is this a driver for an entirely new GMAC device
(designed from scratch) or is it based on an existing IP block?

> +/**
> + * xgmac_init - Entry point for the driver
> + * Description: This function is the entry point for the driver.
> + */
> +static int __init xgmac_init(void)
> +{
> + =A0 =A0 =A0 return platform_driver_register(&xgmac_driver);
> +}
> +module_init(xgmac_init);
> +
> +/**
> + * xgmac_cleanup_module - Cleanup routine for the driver
> + * Description: This function is the cleanup routine for the driver.
> + */
> +static void __exit xgmac_exit(void)
> +{
> + =A0 =A0 =A0 platform_driver_unregister(&xgmac_driver);
> +}
> +module_exit(xgmac_exit);

You can drop some boilerplate with module_platform_driver() now.

g.
