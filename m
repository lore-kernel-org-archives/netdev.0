From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv4: more compliant RFC 3168 support
Date: Mon, 16 May 2011 19:16:44 +0200
Message-ID: <1305566204.2898.49.camel@edumazet-laptop>
References: <201105141938.28344.v13@v13.gr>
	 <1305464176.3120.113.camel@edumazet-laptop>
	 <1305466542.3120.129.camel@edumazet-laptop> <201105151808.39231.v13@v13.gr>
	 <1305475310.3120.146.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stefanos Harhalakis <v13@v13.gr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63465 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab1EPRQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 13:16:48 -0400
Received: by wya21 with SMTP id 21so3602432wya.19
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 10:16:47 -0700 (PDT)
In-Reply-To: <1305475310.3120.146.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 15 mai 2011 =C3=A0 18:01 +0200, Eric Dumazet a =C3=A9crit :

> Problem of this version is that common frames in the Internet (NOT_EC=
T
> or ECT_X or ECT_X) will take the longest path to come to "return 0;"
>=20
> a switch() version is fast because gcc emits a table based jump

Oh well, a table lookup is even faster...

I'll submit another version


