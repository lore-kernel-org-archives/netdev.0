From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [v2,5/9] fsl/fman: Add Frame Manager support
Date: Fri, 26 Jun 2015 01:53:59 +0200
Message-ID: <1435276439.28572.42.camel@tiscali.nl>
References: <1435174555-7008-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	madalin.bucur@freescale.com
To: igal.liberman@freescale.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud3.xs4all.net ([194.109.24.26]:42555 "EHLO
	lb2-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751557AbbFYXyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 19:54:02 -0400
In-Reply-To: <1435174555-7008-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-24 at 22:35 +0300, igal.liberman@freescale.com wrote:
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/fman/fm_drv.c

> +u16 fm_get_max_frm(void)
> +{
> +	return fsl_fm_max_frm;
> +}
> +EXPORT_SYMBOL(fm_get_max_frm);

Which module is using this export? (And what does this function
actually do?)

> +int fm_get_rx_extra_headroom(void)
> +{
> +	return ALIGN(fsl_fm_rx_extra_headroom, 16);
> +}
> +EXPORT_SYMBOL(fm_get_rx_extra_headroom);

This exports an unused function.

I don't know how to, well, review a series that adds almost 20K lines.
So I decided to pick one subject: exports. I think I had something to
comment on all eight of them.

I'm not sure if I'll try another scan with a different subject.

Thanks,


Paul Bolle
