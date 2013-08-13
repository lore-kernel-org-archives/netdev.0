From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 3/7] mfd: core: copy DMA mask and params from parent
Date: Tue, 13 Aug 2013 11:03:40 +0100
Message-ID: <20130813100340.GB5109@lee--X1>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
 <1376384922-8519-5-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:55676 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064Ab3HMKDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 06:03:47 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so3932278ead.21
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 03:03:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1376384922-8519-5-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013, Benedikt Spranger wrote:

> The child device intends to perform DMA operations then it needs a dm=
a
> mask and params set. This patches copies them from the parent device.
>=20
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Cc: Lee Jones <lee.jones@linaro.org>
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> Signed-off-by: Holger Dengler <dengler@linutronix.de>
> ---
>  drivers/mfd/mfd-core.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/mfd/mfd-core.c b/drivers/mfd/mfd-core.c
> index 7604f4e..f421586 100644
> --- a/drivers/mfd/mfd-core.c
> +++ b/drivers/mfd/mfd-core.c
> @@ -96,6 +96,8 @@ static int mfd_add_device(struct device *parent, in=
t id,
> =20
>  	pdev->dev.parent =3D parent;
>  	pdev->dev.type =3D &mfd_dev_type;
> +	pdev->dev.dma_mask =3D parent->dma_mask;
> +	pdev->dev.dma_parms =3D parent->dma_parms;
> =20
>  	if (parent->of_node && cell->of_compatible) {
>  		for_each_child_of_node(parent->of_node, np) {

Patch applied, thanks.

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
