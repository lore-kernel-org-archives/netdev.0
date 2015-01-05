From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] ip: Add support for IP_CHECKSUM cmsg
Date: Mon, 05 Jan 2015 16:12:45 -0500 (EST)
Message-ID: <20150105.161245.321583390793752509.davem@davemloft.net>
References: <1420488035-24866-1-git-send-email-therbert@google.com>
	<1420488035-24866-5-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60516 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbbAEVMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:12:47 -0500
In-Reply-To: <1420488035-24866-5-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon,  5 Jan 2015 12:00:35 -0800

> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index 4091fab..2823fc0 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -203,6 +203,7 @@ struct inet_sock {
>  #define IP_CMSG_RETOPTS		(1 << 4)
>  #define IP_CMSG_PASSSEC		(1 << 5)
>  #define IP_CMSG_ORIGDSTADDR	(1 << 6)
> +#define IP_CMSG_CHECKSUM	(1 << 7)

Likewise, please include linux/bitops.h and use "BIT()" for this.

Thanks.
