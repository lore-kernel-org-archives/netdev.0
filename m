From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv4: more compliant RFC 3168 support
Date: Mon, 16 May 2011 23:38:38 +0200
Message-ID: <1305581918.9466.10.camel@edumazet-laptop>
References: <201105141938.28344.v13@v13.gr>
	 <1305464176.3120.113.camel@edumazet-laptop>
	 <1305466542.3120.129.camel@edumazet-laptop> <201105151808.39231.v13@v13.gr>
	 <1305475310.3120.146.camel@edumazet-laptop>
	 <20110516213336.GD3290@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefanos Harhalakis <v13@v13.gr>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59934 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab1EPVin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:38:43 -0400
Received: by wwa36 with SMTP id 36so5594591wwa.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 14:38:41 -0700 (PDT)
In-Reply-To: <20110516213336.GD3290@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 mai 2011 =C3=A0 23:33 +0200, Hagen Paul Pfeifer a =C3=A9cri=
t :
> * Eric Dumazet | 2011-05-15 18:01:50 [+0200]:
>=20
> >Problem of this version is that common frames in the Internet (NOT_E=
CT
> >or ECT_X or ECT_X) will take the longest path to come to "return 0;"
> >
> >a switch() version is fast because gcc emits a table based jump
>=20
> Sure? Is the table access not an dCache miss? E.g.
>=20
> 4003dc: ff 24 fd 58 06 40 00  jmpq   *0x400658(,%rdi,8)
>=20
> Not sure if jump table access is superior these days ...
>=20

Check v2 of patch, it is fine, small, fast ;)

By the way, you dont want to know how many cpu cycles we spend in IP
defrag functions... Really its insane.



