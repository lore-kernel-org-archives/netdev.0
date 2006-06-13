From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 14:07:16 +0900
Message-ID: <20060613140716.6af45bec@localhost.localdomain>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23735 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932877AbWFMFI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 01:08:57 -0400
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Jun 2006 16:56:01 -0700
Sridhar Samudrala <sri@us.ibm.com> wrote:

> This patch makes it convenient to use the sockets API by the in-kernel
> users like sunrpc, cifs & ocfs2 etc and any future users.
> Currently they get to this API by directly accesing the function pointers
> in the sock structure.
> 
> Most of these functions are pretty simple and can be made inline and moved
> to linux/net.h.

...

> @@ -2176,3 +2279,13 @@ EXPORT_SYMBOL(sock_wake_async);
>  EXPORT_SYMBOL(sockfd_lookup);
>  EXPORT_SYMBOL(kernel_sendmsg);
>  EXPORT_SYMBOL(kernel_recvmsg);
> +EXPORT_SYMBOL(kernel_bind);
> +EXPORT_SYMBOL(kernel_listen);
> +EXPORT_SYMBOL(kernel_accept);
> +EXPORT_SYMBOL(kernel_connect);
> +EXPORT_SYMBOL(kernel_getsockname);
> +EXPORT_SYMBOL(kernel_getpeername);
> +EXPORT_SYMBOL(kernel_getsockopt);
> +EXPORT_SYMBOL(kernel_setsockopt);
> +EXPORT_SYMBOL(kernel_sendpage);
> +EXPORT_SYMBOL(kernel_ioctl);

Don't we want to restrict this to GPL code with EXPORT_SYMBOL_GPL?
