From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Remove deprecated print_mac to fix warnings
Date: Sun, 06 Dec 2009 10:10:57 -0800
Message-ID: <1260123057.11126.93.camel@Joe-Laptop.home>
References: <20091206140828.GA8600@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1067 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934035AbZLFSKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2009 13:10:52 -0500
In-Reply-To: <20091206140828.GA8600@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-12-06 at 15:08 +0100, Andi Kleen wrote:
> Remove deprecated and unused print_mac to fix warnings
[]
> --- linux-2.6.32-ak.orig/include/linux/if_ether.h
> +++ linux-2.6.32-ak/include/linux/if_ether.h
> @@ -139,7 +139,6 @@ extern ssize_t sysfs_format_mac(char *bu
>  /*
>   *	Display a 6 byte device address (MAC) in a readable format.
>   */
> -extern char *print_mac(char *buf, const unsigned char *addr) __deprecated;
>  #define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
>  #define MAC_BUF_SIZE	18
>  #define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE]

#define MAC_BUF_SIZE and #define DECLARE_MAC_BUF
should be removed as well.


