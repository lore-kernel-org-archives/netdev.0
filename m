From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: avoid useless call of the function check_peer_pmtu
Date: Thu, 20 Oct 2011 06:30:41 +0200
Message-ID: <1319085041.8416.39.camel@edumazet-laptop>
References: <1319074449-10892-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53158 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1JTEbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 00:31:12 -0400
Received: by wwe6 with SMTP id 6so3554292wwe.1
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 21:31:11 -0700 (PDT)
In-Reply-To: <1319074449-10892-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 09:34 +0800, Gao feng a =C3=A9crit :
> In func ipv4_dst_check,check_peer_pmtu should be called only when pee=
r is updated.
> So,if the peer is not updated in ip_rt_frag_needed,we can not inc __r=
t_peer_genid.
>=20
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
