From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/3] net: do not manually initialize enumerators
Date: Sat, 01 Jun 2013 19:40:03 -0700
Message-ID: <1370140803.2086.0.camel@joe-AO722>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
	 <1370139797-8912-2-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43769 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750779Ab3FBCkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jun 2013 22:40:05 -0400
In-Reply-To: <1370139797-8912-2-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-01 at 20:23 -0600, Jean Sacren wrote:
> Clean up unnecessary initialization of enumerators as the compiler takes
> care of that.
[]
> diff --git a/include/linux/net.h b/include/linux/net.h
[]
>  enum sock_shutdown_cmd {
> -	SHUT_RD		= 0,
> -	SHUT_WR		= 1,
> -	SHUT_RDWR	= 2,
> +	SHUT_RD,
> +	SHUT_WR,
> +	SHUT_RDWR,
>  };

The compiler may do the same thing,
but specificity is good.
