From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-next-2.6] cleanup: remove unused parameter from fill
 	method in fib_rules_ops.
Date: Wed, 20 May 2009 08:57:58 +0200
Message-ID: <4A13A9F6.7080800@cosmosbay.com>
References: <eb3ff54b0905190554i6293ebdfw6b06d54f1cd82f5b@mail.gmail.com>	 <20090519.151857.56095864.davem@davemloft.net> <eb3ff54b0905192350w4aa0f411q26ac8e460f51b29f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38569 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbZETG6G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 02:58:06 -0400
In-Reply-To: <eb3ff54b0905192350w4aa0f411q26ac8e460f51b29f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rami Rosen a =E9crit :
> Hi,
> This fixes the  for the space-tab sequences  and
> multi-line tabbing. Sorry.
>=20
> The netlink message header (struct nlmsghdr) is an unused parameter i=
n
> fill method of fib_rules_ops struct.
> This patch removes this parameter from this method and fixes the plac=
es
> where this method is called.
>=20
> (include/net/fib_rules.h)
>=20
>=20
>=20
> Regards,
> Rami Rosen
>=20
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
>=20

 static int fib6_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
-			  struct nlmsghdr *nlh, struct fib_rule_hdr *frh)
+			                    struct fib_rule_hdr *frh)


extra spaces after tabs.... it should be :

 static int fib6_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
-			  struct nlmsghdr *nlh, struct fib_rule_hdr *frh)
+			  struct fib_rule_hdr *frh)




