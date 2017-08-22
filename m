From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/6] fsl/fman: enable FMan Keygen
Date: Tue, 22 Aug 2017 14:35:10 -0700 (PDT)
Message-ID: <20170822.143510.1048652578169181274.davem@davemloft.net>
References: <1503423066-15420-1-git-send-email-madalin.bucur@nxp.com>
        <1503423066-15420-2-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503423066-15420-2-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Tue, 22 Aug 2017 20:31:01 +0300

>  /**
> + * fman_get_keygen
> + *
> + * @fman:	A Pointer to FMan device
> + *
> + * Get the handle to KeyGen module part of FM driver
> + *
> + * Return: Handle to KeyGen
> + */
> +struct fman_keygen *fman_get_keygen(struct fman *fman)
> +{
> +	return fman->keygen;
> +}
> +EXPORT_SYMBOL(fman_get_keygen);

Please don't do this.

Just directly derefence the pointer in the source code to
get the keygen.

Thank you.
