From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vxlan: Do not reuse sockets for a different
 address family
Date: Wed, 05 Nov 2014 15:59:13 -0500 (EST)
Message-ID: <20141105.155913.297158120451064287.davem@davemloft.net>
References: <e7e226e9bef6f03ac249bc8e5ebf0938944ace3c.1415120464.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	sergei.shtylyov@cogentembedded.com
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaKEU7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:59:16 -0500
In-Reply-To: <e7e226e9bef6f03ac249bc8e5ebf0938944ace3c.1415120464.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Tue,  4 Nov 2014 15:03:20 -0200

> @@ -281,7 +281,8 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
>  	struct vxlan_sock *vs;
>  
>  	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
> -		if (inet_sk(vs->sock->sk)->inet_sport == port)
> +		if (inet_sk(vs->sock->sk)->inet_sport == port &&
> +		    inet_sk(vs->sock->sk)->sk.sk_family == family)

You didn't even compile this.

You're in the penalty box, and I'm ignoring your patches for at least
a week, this is really unacceptable for an upstream patch submission.

Sorry.
