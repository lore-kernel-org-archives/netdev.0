From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] [70/2many] MAINTAINERS - ARPD SUPPORT
Date: Mon, 13 Aug 2007 11:49:42 +0100
Message-ID: <20070813114942.04a5483c@the-village.bc.nu>
References: <46bff8e8.HhTQ7TBPy1zkcNfh%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:38734 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S939684AbXHMKnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 06:43:07 -0400
In-Reply-To: <46bff8e8.HhTQ7TBPy1zkcNfh%joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 12 Aug 2007 23:23:36 -0700
joe@perches.com wrote:

> Add file pattern to MAINTAINER entry
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 90c1b81..ac2226b 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -697,6 +697,7 @@ ARPD SUPPORT
>  P:	Jonathan Layes
>  L:	netdev@vger.kernel.org
>  S:	Maintained
> +F:	net/ipv4/arp.c

NAK

arp.c is the netdev people, ARPD is a corner case bit of code within it,
something your patterns don't actually cope with
