From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce SO_MAX_PACING_RATE
Date: Tue, 24 Sep 2013 08:14:00 -0700
Message-ID: <1380035640.3165.68.camel@edumazet-glaptop>
References: <1379949014.3165.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:43418 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab3IXPOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:14:03 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so4716990pbc.29
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 08:14:02 -0700 (PDT)
In-Reply-To: <1379949014.3165.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 08:10 -0700, Eric Dumazet wrote:

> +
> +	case SO_MAX_PACING_RATE:
> +		sk->sk_max_pacing_rate = val;
> +		break;
> +

I'll send a v2, adding here :

sk->sk_pacing_rate = min(sk->sk_pacing_rate, sk->max_pacing_rate);

to enforce current limit for non TCP protocols.
