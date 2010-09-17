From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 NEXT 1/5] qlcnic: support vlan rx accleration
Date: Fri, 17 Sep 2010 07:29:43 +0200
Message-ID: <1284701383.4784.34.camel@edumazet-laptop>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
	 <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50816 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab0IQF3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 01:29:48 -0400
Received: by wyf22 with SMTP id 22so2053807wyf.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 22:29:46 -0700 (PDT)
In-Reply-To: <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 septembre 2010 =C3=A0 22:14 -0700, Amit Kumar Salecha a =C3=
=A9crit :
> Implemented vlan rx accleration in driver.
> This helps in increasing significant performance and
> reduces cpu utilization with GRO and LRO.
>=20
> Eric Dumazet:
> 	"Its a bit strange you use dev_kfree_skb_any(skb) here."
> 	"We run in NAPI mode, so you can use dev_kfree_skb()."
> Amit:
> 	Done. Using dev_kfree_skb();
>=20
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


