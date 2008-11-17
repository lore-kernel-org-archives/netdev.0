From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Cleanup of af_unix
Date: Sun, 16 Nov 2008 23:34:42 -0800
Message-ID: <1226907282.4037.31.camel@localhost>
References: <49210AE7.3050405@cosmosbay.com>
	 <20081116.223209.239966240.davem@davemloft.net>
	 <4921133D.6070800@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2856 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758648AbYKQHen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:34:43 -0500
In-Reply-To: <4921133D.6070800@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-17 at 07:46 +0100, Eric Dumazet wrote:
> [PATCH] net: Cleanup of af_unix
> 
> This is a pure cleanup of net/unix/af_unix.c to meet current code style standards
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> --- 
>  net/unix/af_unix.c |  117 ++++++++++++++++++++-----------------------
>  1 files changed, 55 insertions(+), 62 deletions(-)
> plain text document attachment (af_unix_cleanup.patch)
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 4a39771..58db2a2 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -354,7 +353,7 @@ static void unix_sock_destructor(struct sock *sk)
>  	WARN_ON(!sk_unhashed(sk));
>  	WARN_ON(sk->sk_socket);
>  	if (!sock_flag(sk, SOCK_DEAD)) {
> -		printk("Attempt to release alive unix socket: %p\n", sk);
> +		printk(KERN_DEBUG "Attempt to release alive unix socket: %p\n", sk);
>  		return;
>  	}
>  

Well, perhaps not quite pure.
The KERN_ level selection is debatable.
This could or perhaps should be KERN_INFO.


