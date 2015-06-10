From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v3 net-next 1/2] tcp: export tcp_enter_cwr()
Date: Wed, 10 Jun 2015 11:43:37 -0700
Message-ID: <CAK6E8=fPE3a8EGraks-EdYGXMcmTEAAxOhRcFLQ1nhzNJKwo3A@mail.gmail.com>
References: <1433956097-6186-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Neal Cardwell <ncardwell@google.com>,
	David Hayes <davihay@ifi.uio.no>,
	Andreas Petlund <apetlund@simula.no>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Nicolas Kuhn <nicolas.kuhn@telecom-bretagne.eu>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34009 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbbFJSoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 14:44:21 -0400
Received: by obbsn1 with SMTP id sn1so17815903obb.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 11:44:21 -0700 (PDT)
In-Reply-To: <1433956097-6186-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 10:08 AM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
>
> Upcoming tcp_cdg uses tcp_enter_cwr() to initiate PRR. Export this
> function so that CDG can be compiled as a module.
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: David Hayes <davihay@ifi.uio.no>
> Cc: Andreas Petlund <apetlund@simula.no>
> Cc: Dave Taht <dave.taht@bufferbloat.net>
> Cc: Nicolas Kuhn <nicolas.kuhn@telecom-bretagne.eu>
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
> ---
Acked-by: Yuchung Cheng <ycheng@google.com>

> V3: rebase
> ---
>  net/ipv4/tcp_input.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 15c4536..d4f76ab 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2552,6 +2552,7 @@ void tcp_enter_cwr(struct sock *sk)
>                 tcp_set_ca_state(sk, TCP_CA_CWR);
>         }
>  }
> +EXPORT_SYMBOL(tcp_enter_cwr);
>
>  static void tcp_try_keep_open(struct sock *sk)
>  {
> --
> 2.1.0
>
