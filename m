From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v1 2/2] TCPCT API sockopt update to draft -03
Date: Wed, 12 Jan 2011 10:56:08 -0800
Message-ID: <20110112105608.793787b2@s6510>
References: <4D2DE824.10205@gmail.com>
	<4D2DEC0A.70608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46226 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755066Ab1ALS4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 13:56:12 -0500
In-Reply-To: <4D2DEC0A.70608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Jan 2011 12:59:38 -0500
William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index e64f4c6..c8f4017 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -185,22 +185,37 @@ struct tcp_md5sig {
>  #define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
>  
>  /* Flags for both getsockopt and setsockopt */
> -#define TCP_COOKIE_IN_ALWAYS	(1 << 0)	/* Discard SYN without cookie */
> -#define TCP_COOKIE_OUT_NEVER	(1 << 1)	/* Prohibit outgoing cookies,
> +#define TCPCT_IN_ALWAYS		(1 << 0)	/* Discard SYN without cookie */
> +#define TCPCT_OUT_NEVER		(1 << 1)	/* Prohibit outgoing cookies,

You end up changing values in kernel userspace API in a way
that is incompatible with older applications. This is not acceptable.
