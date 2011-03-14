From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/7] tcp_cubic: fix clock dependency
Date: Mon, 14 Mar 2011 22:37:04 +0100
Message-ID: <1300138624.2649.21.camel@edumazet-laptop>
References: <20110314175211.788224699@vyatta.com>
	 <20110314175439.564307922@vyatta.com>
	 <1300128679.3423.167.camel@edumazet-laptop>
	 <20110314142125.63e84ade@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60797 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983Ab1CNVhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:37:12 -0400
Received: by fxm17 with SMTP id 17so3401596fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 14:37:11 -0700 (PDT)
In-Reply-To: <20110314142125.63e84ade@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 14:21 -0700, Stephen Hemminger a =C3=A9cri=
t :

> I choose get_real() because that is what skb timestamp is using;
> both should probably use monotonic clock.
>=20
>=20

This point was raised elsewhere, problem is tcpdump/libpcap probably
wants "real" time, not monotonic clock...



