From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] TCP: Add comments to (near) all functions in tcp_output.c
 v2
Date: Mon, 20 Jul 2009 20:06:53 +0800
Message-ID: <4A645DDD.8050402@cn.fujitsu.com>
References: <20090717204004.GA516@basil.fritz.box> <Pine.LNX.4.64.0907180919270.31457@melkinkari.cs.Helsinki.FI> <20090718103159.GB2682@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54434 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbZGTMGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2009 08:06:55 -0400
In-Reply-To: <20090718103159.GB2682@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen said:
> =20
> +/* Compute TCP options for ESTABLISHED sockets. This is not the
> + * final wire format yet.
> + */

typo, =E2=80=9Cnetwork wire=E2=80=9D?


> +/* Test if sending is allowed right now.
> + */
>  int tcp_may_send_now(struct sock *sk)

Is it better to provide the condition be allowed?

+ /* Check the nagle, the congestion window and=20
+  * the send window, decide if sending is allowed right now.
+  */
