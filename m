From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] sock-diag: Report shutdown for inet and unix
 sockets
Date: Tue, 23 Oct 2012 18:53:14 +0200
Message-ID: <1351011194.8609.2301.camel@edumazet-glaptop>
References: <5086C36B.6060508@parallels.com>
	 <5086C5A6.7050101@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63281 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932930Ab2JWQxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 12:53:19 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1694515bkc.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 09:53:17 -0700 (PDT)
In-Reply-To: <5086C5A6.7050101@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-23 at 20:28 +0400, Pavel Emelyanov wrote:
> Add ext bits for inet-diag and unix-diag and report sk_shutdown state.

>  
> +	if (ext & (1 << (INET_DIAG_SHUTDOWN - 1)))
> +		if (sock_diag_put_shutdown(sk, skb, INET_DIAG_SHUTDOWN))
> +			goto errout;
> +

I dont feel the need to make this conditional and consume one bit.
