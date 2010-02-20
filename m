From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] packet: convert socket list to RCU (v3)
Date: Sat, 20 Feb 2010 04:39:26 +0100
Message-ID: <1266637166.2839.1.camel@edumazet-laptop>
References: <20100219215913.819285957@vyatta.com>
	 <20100219220111.772997037@vyatta.com>  <20100219142359.467b9440@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Peter Oberparleiter <oberpar@linux.vnet.ibm.com>,
	Miklos Szeredi <mszeredi@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:47087 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab0BTDjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 22:39:32 -0500
Received: by bwz1 with SMTP id 1so561321bwz.21
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 19:39:30 -0800 (PST)
In-Reply-To: <20100219142359.467b9440@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 f=C3=A9vrier 2010 =C3=A0 14:23 -0800, Stephen Hemminger =
a =C3=A9crit :
> Convert AF_PACKET to use RCU, eliminating one more reader/writer lock=
=2E
>=20
> There is no need for a real sk_del_node_init_rcu(), because sk_del_no=
de_init
> is doing the equivalent thing to hlst_del_init_rcu already; but added
> some comments to try and make that obvious.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> v2 - > v3: Need to not call remove_packet with lock held.
>=20
>  include/net/netns/packet.h |    4 ++--
>  include/net/sock.h         |   10 ++++++++++
>  net/packet/af_packet.c     |   42 ++++++++++++++++++++--------------=
--------
>  3 files changed, 32 insertions(+), 24 deletions(-)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Stephen


