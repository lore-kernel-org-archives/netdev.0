From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp_timer.c: Add kernel-doc function descriptions
Date: Mon, 11 Jul 2016 12:56:30 -0700 (PDT)
Message-ID: <20160711.125630.317058844992527133.davem@davemloft.net>
References: <1468011506-358-1-git-send-email-richard@weltraumpflege.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org
To: richard@weltraumpflege.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbcGKT4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 15:56:32 -0400
In-Reply-To: <1468011506-358-1-git-send-email-richard@weltraumpflege.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Sailer <richard@weltraumpflege.org>
Date: Fri,  8 Jul 2016 22:58:26 +0200

>  
> +/**
> + *   tcp_write_err() - close socket and save error info.
> + *   @sk:  The socket the error has appeared on.
> + *
> + *   Returns: Nothing (void)
> + */
> +
...
> +/**
> + * tcp_out_of_resources() - Close socket if out of resources
> + * @sk:        pointer to current socket
> + * @do_reset:  send a last packet with reset flag
> + *
> + * Do not allow orphaned sockets to eat all our resources.
>   * This is direct violation of TCP specs, but it is required
>   * to prevent DoS attacks. It is called when a retransmission timeout
>   * or zero probe timeout occurs on orphaned socket.

Please indent your comments consistently.
