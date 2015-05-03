From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] sock: fix comment location
Date: Sun, 3 May 2015 23:05:34 +0200
Message-ID: <20150503210534.GG22481@breakpoint.cc>
References: <1430686519-20548-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: =?utf-8?B?Ss61YW4=?= Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44757 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751186AbbECVFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 17:05:36 -0400
Content-Disposition: inline
In-Reply-To: <1430686519-20548-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

J=CE=B5an Sacren <sakiwit@gmail.com> wrote:
> From: Jean Sacren <sakiwit@gmail.com>
>=20
> The block of comment is for 'sk_incoming_cpu' rather than 'sk_txhash'=
=2E
> Therefore, move it above "u16 sk_incoming_cpu;" where it belongs.

comment is at the right place.

> diff --git a/include/net/sock.h b/include/net/sock.h
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> -	u16			sk_incoming_cpu;
>  	/* 16bit hole
>  	 * Warned : sk_incoming_cpu can be set from softirq,
>  	 * Do not use this hole without fully understanding possible issues=
=2E
>  	 */
> +	u16			sk_incoming_cpu;

This hole is between sk_incoming_cpu and sk_txhash.
