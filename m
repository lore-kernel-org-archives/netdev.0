From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] LISP: Locator/Identifier Separation Protocol
Date: Tue, 3 Jun 2014 15:16:21 -0700
Message-ID: <20140603151621.2e4a73ba@nehalam.linuxnetplumber.net>
References: <E5B7A820-EF96-4F50-81F8-DE7714105D89@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:65008 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965067AbaFCWQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 18:16:26 -0400
Received: by mail-pd0-f176.google.com with SMTP id p10so5179842pdj.7
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 15:16:25 -0700 (PDT)
In-Reply-To: <E5B7A820-EF96-4F50-81F8-DE7714105D89@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 May 2014 14:05:29 -0700
Christopher White <chris@logicalelegance.com> wrote:

> +#define LISP_VERSION "0.1"
> +
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 36)
> +#define rt_dst(rt) (rt->dst)
> +#else
> +#define rt_dst(rt) (rt->u.dst)
> +#endif
> +

Upstream kernel submissions should never include kernel version
checks. Remove these and get rid of the wrapper.
