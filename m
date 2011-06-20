From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/5] netxen: make 64 bit stats safe on 32 bit
 platform
Date: Mon, 20 Jun 2011 23:50:57 +0200
Message-ID: <1308606657.2658.35.camel@edumazet-laptop>
References: <20110620203506.363818794@vyatta.com>
	 <20110620203602.836836605@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Amit Kumar Salecha <amit.salecha@qlogic.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56835 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab1FTVvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:51:01 -0400
Received: by wwe5 with SMTP id 5so2990721wwe.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 14:51:00 -0700 (PDT)
In-Reply-To: <20110620203602.836836605@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 13:35 -0700, Stephen Hemminger a =C3=A9cri=
t :
> pi=C3=A8ce jointe document texte brut (netxen-stats-sync.patch)
> Use stats_update wrapper to avoid problems where 64 bit statistic upd=
ate
> is not atomic on 32 bit platform.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Same remark than ifb : You need to be careful not having two different
cpus doing an u64_stats_update_begin(one_syncp);

(Separate rx & tx)


