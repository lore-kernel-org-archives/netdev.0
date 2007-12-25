From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] via-velocity big-endian support
Date: Tue, 25 Dec 2007 23:43:33 +0100
Message-ID: <20071225224333.GA21585@electric-eye.fr.zoreil.com>
References: <20071224050659.GS8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37307 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751130AbXLYWxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 17:53:02 -0500
Content-Disposition: inline
In-Reply-To: <20071224050659.GS8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ftp.linux.org.uk> :
[...]
> diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
> index aa91796..e0ec5d4 100644
> --- a/drivers/net/via-velocity.h
> +++ b/drivers/net/via-velocity.h
> @@ -196,26 +196,29 @@
>   *	Receive descriptor
>   */
>  
> +#define DESC_OWNER cpu_to_le16(0x8000)
> +

DESC_OWNER does not seem to be used.

[...]
> +enum {
> +	RX_INTEN = __constant_cpu_to_le16(0x8000)
> +};

Can we avoid using cpu_to_leXY here for consistency sake within the driver
(and among different drivers as well) ?

-- 
Ueimor
