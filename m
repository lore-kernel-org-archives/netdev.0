From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: proc: Fix error handling
Date: Fri, 16 Dec 2011 13:21:01 +0100
Message-ID: <1324038061.2273.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <igorm@etf.rs> <1324037139-3626-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:40607 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab1LPMVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 07:21:06 -0500
Received: by wibhm6 with SMTP id hm6so197617wib.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 04:21:04 -0800 (PST)
In-Reply-To: <1324037139-3626-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 13:05 +0100, igorm@etf.rs a =C3=
=A9crit :
> From: Igor Maravic <igorm@etf.rs>
>=20
> Fix error handling in case making of dir dev_snmp6 failes
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
> ---
>  net/ipv6/proc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
> index fdeb6d0..6df9035 100644
> --- a/net/ipv6/proc.c
> +++ b/net/ipv6/proc.c
> @@ -307,10 +307,10 @@ static int __net_init ipv6_proc_init_net(struct=
 net *net)
>  		goto proc_dev_snmp6_fail;
>  	return 0;
> =20
> +proc_dev_snmp6_fail:
> +	proc_net_remove(net, "snmp6");
>  proc_snmp6_fail:
>  	proc_net_remove(net, "sockstat6");
> -proc_dev_snmp6_fail:
> -	proc_net_remove(net, "dev_snmp6");
>  	return -ENOMEM;
>  }
> =20

Good catch, thanks !

(Should probably be applied on net tree, not net-next)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
