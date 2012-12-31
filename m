From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: split tcp_ecn sysctl knob to distinguish between
 IPv4 and IPv6
Date: Mon, 31 Dec 2012 14:04:12 -0800
Message-ID: <20121231140412.7dee9821@nehalam.linuxnetplumber.net>
References: <20121231173532.GA11700@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47917 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090Ab2LaWFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 17:05:35 -0500
In-Reply-To: <20121231173532.GA11700@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Dec 2012 18:35:33 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> diff --git a/include/net/sock.h b/include/net/sock.h
> index 182ca99..aa3c30e 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -944,6 +944,7 @@ struct proto {
>  	int			*sysctl_rmem;
>  	int			max_header;
>  	bool			no_autobind;
> +	int			ecn;
>  
Why isn't this a bool?
