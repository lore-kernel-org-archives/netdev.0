From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v2,4/9] fsl/fman: Add FMan MURAM support
Date: Thu, 25 Jun 2015 20:59:09 -0500
Message-ID: <1435283949.4306.16.camel@freescale.com>
References: <1435174496-7472-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	madalin.bucur@freescale.com, pebolle@tiscali.nl
To: igal.liberman@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0114.outbound.protection.outlook.com ([157.56.110.114]:49378
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752018AbbFZB7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 21:59:18 -0400
In-Reply-To: <1435174496-7472-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-24 at 22:34 +0300, igal.liberman@freescale.com wrote:
> +     struct muram_info *p_muram;

No Hungarian notation.

> +void fm_muram_free(struct muram_info *p_muram)
> +{
> +     /* Destroy pool */
> +     gen_pool_destroy(p_muram->pool);
> +     /* Unmap memory */
> +     iounmap(p_muram->vbase);
> +     /* Free pointer */
> +     kfree(p_muram);
> +}

This type of commenting is not useful.

> +     memset_io((void __iomem *)vaddr, 0, (int)size);

Unnecessary cast of size.

-Scott
