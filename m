From: Lance Richardson <lrichard@redhat.com>
Subject: Fwd: [PATCH net 0/3] ipv4: fix various issues reported by sparse
Date: Wed, 6 Jan 2016 18:08:34 -0500 (EST)
Message-ID: <1921532308.9305704.1452121714559.JavaMail.zimbra@redhat.com>
References: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:36893 "EHLO
	mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbcAFXJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:09:16 -0500
In-Reply-To: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Forwarded Message -----
> This trivial patch series addresses a number of endianness- and
> lock-related issues reported by sparse.
> 
> Lance Richardson (3):
>   ipv4: fix endianness warnings in ip_tunnel_core.c
>   ipv4: eliminate endianness warnings in ip_fib.h
>   ipv4: eliminate lock count warnings in ping.c
> 
>  include/net/ip_fib.h      |  3 ++-
>  net/ipv4/ip_tunnel_core.c | 16 ++++++++--------
>  net/ipv4/ping.c           |  2 ++
>  3 files changed, 12 insertions(+), 9 deletions(-)
> 
> --
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Apologies, I must have fumbled the "--cc-cmd=" option to git send-email.

Resending cover letter with cc: list.
