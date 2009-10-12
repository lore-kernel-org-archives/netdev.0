From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [PATCH] [CAIF-RFC 1/8-v2] CAIF Protocol Stack
Date: Mon, 12 Oct 2009 10:08:36 +0200
Message-ID: <4AD2E404.80704@babic.homelinux.org>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout13.attiva.biz ([85.37.16.15]:18539 "EHLO
	smtpout13.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606AbZJLIJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 04:09:33 -0400
In-Reply-To: <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Change-Id: I305056f116a11c31265f65ac0fe285e2b655dd54
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
> ---
>  include/linux/caif/caif_config.h |  203 ++++++++++++++++++++++++++++++++++++++
>  include/linux/caif/caif_ioctl.h  |  113 +++++++++++++++++++++
>  2 files changed, 316 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/caif/caif_config.h
>  create mode 100644 include/linux/caif/caif_ioctl.h
> 
> diff --git a/include/linux/caif/caif_config.h b/include/linux/caif/caif_config.h
> new file mode 100644
> index 0000000..6ea934b
> --- /dev/null
> +++ b/include/linux/caif/caif_config.h
> @@ -0,0 +1,203 @@
> +/*
> + *	Copyright (C) ST-Ericsson AB 2009
> + *
> + *	CAIF Channel Configuration definitions.
> + *
> + *	Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
> + *
> + *	License terms: GNU General Public License (GPL), version 2.

In the majority of linux drivers we find the following statements to set
up the license terms :

 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.

> + * \b Documentation see STE Doc No: 155 19-CRH 109 913.

Probably you should remove this line as you already did in other places.

> diff --git a/include/linux/caif/caif_ioctl.h b/include/linux/caif/caif_ioctl.h

> +/* Use 'g' as magic number. 'g' is the first free letter in
> + * Documentation/ioctl-number.txt*/

The file is Documentation/ioctl/ioctl-number.txt

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
