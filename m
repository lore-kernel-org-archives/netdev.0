From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 4/5][RFC] Implement devm_kcalloc
Date: Fri, 3 Aug 2007 18:20:54 +0900
Message-ID: <20070803092054.GM13674@htj.dyndns.org>
References: <20070802224545.GF5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, teheo@suse.de,
	Brandon Philips <bphilips@suse.de>
To: Brandon Philips <brandon@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:50682 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756930AbXHCJVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 05:21:03 -0400
Received: by wa-out-1112.google.com with SMTP id v27so794906wah
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2007 02:21:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070802224545.GF5181@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 03:45:45PM -0700, Brandon Philips wrote:
>  /**
> + * devm_kcalloc - resource-managed kcalloc
> + * @dev: Device to allocate memory for
> + * @n: number of elements.
> + * @size: element size.
> + * @flags: the type of memory to allocate.
> + */
> +inline void * devm_kcalloc(struct device * dev, size_t n, size_t size,
> +			   gfp_t flags)
> +{
> +        if (n != 0 && size > ULONG_MAX / n)
> +                return NULL;
> +        return devm_kzalloc(dev, n * size, flags);
> +}
> +EXPORT_SYMBOL_GPL(devm_kcalloc);

Please drop inline.  It's meaningless.

Other than that, Acked-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
