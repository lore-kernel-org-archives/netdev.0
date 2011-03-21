From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netxen: fix LRO disable warning
Date: Mon, 21 Mar 2011 11:47:54 +0100
Message-ID: <1300704474.2884.66.camel@edumazet-laptop>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38965 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab1CUKr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 06:47:58 -0400
Received: by fxm17 with SMTP id 17so5336425fxm.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 03:47:57 -0700 (PDT)
In-Reply-To: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 mars 2011 =C3=A0 03:37 -0700, Amit Kumar Salecha a =C3=A9cr=
it :
> netxen_nic_set_flags() rejects data if other flag than ETH_FLAG_LRO i=
s set.
> Driver also supports NETIF_F_HW_VLAN_TX.
> Now compare data with ethtool_op_get_flags(), to get all supported fe=
atures.
>=20
> Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> ---

Hmm, it would be really nice you provide more information for stable
teams.

If I am not mistaken, bug was introduced in 2.6.36 ?



