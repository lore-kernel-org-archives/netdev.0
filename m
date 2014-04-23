From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH net-next v4 3/3] net: ipv6: Use ip6_datagram_send_common
 in ping.
Date: Wed, 23 Apr 2014 13:11:20 +0200
Message-ID: <53579FD8.2090309@enst-bretagne.fr>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com> <1398235078-27088-1-git-send-email-lorenzo@google.com> <1398235078-27088-3-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:46144 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153AbaDWLRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:17:19 -0400
In-Reply-To: <1398235078-27088-3-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/04/2014 17:14, Lorenzo Colitti a =E9crit :> +
> +		if (sin6->sin6_family !=3D AF_INET6)
> +			return -EAFNOSUPPORT;
> +

It has before returned -EINVAL, it changes the return to the user space=
=2E
You made it consistent with other protocols, but perhaps should you add
a notice in the commit changelog?

> -		if (sk->sk_bound_dev_if &&
> -		    sk->sk_bound_dev_if !=3D u->sin6_scope_id) {
> -			return -EINVAL;
> -		}

What about this check now ?


Very good idea to simplify it, by the way.
