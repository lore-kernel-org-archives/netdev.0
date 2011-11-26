From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet:
Date: Sat, 26 Nov 2011 23:16:30 +0100
Message-ID: <1322345790.10212.23.camel@edumazet-laptop>
References: <201111231910.37190.a.miskiewicz@gmail.com>
	 <1322077447.2775.6.camel@edumazet-laptop>
	 <201111232135.55122.a.miskiewicz@gmail.com>
	 <201111251853.19551.a.miskiewicz@gmail.com>
	 <1322345624.10212.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Arkadiusz =?UTF-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39827 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754958Ab1KZWQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 17:16:34 -0500
Received: by mail-bw0-f46.google.com with SMTP id 11so6194766bke.19
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2011 14:16:33 -0800 (PST)
In-Reply-To: <1322345624.10212.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 26 novembre 2011 =C3=A0 23:13 +0100, Eric Dumazet a =C3=A9cri=
t :
> Now inetpeer is the place where we cache redirect information for ipv=
4
> destinations, we must be able to invalidate informations when a route=
 is
> added/removed on host.
>=20
> As inetpeer is not yet namespace aware, this patch adds a shared
> redirect_genid, and a per inetpeer redirect_genid. This might be chan=
ged
> later if inetpeer becomes ns aware.
>=20
> Cache information for one inerpeer is valid as long as its
> redirect_genid has the same value than global redirect_genid.
>=20
> Reported-by: Arkadiusz Mi=C5=9Bkiewicz <a.miskiewicz@gmail.com>
> Tested-by: Arkadiusz Mi=C5=9Bkiewicz <a.miskiewicz@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Arg, patch title was not complete, it could be :

[PATCH] inet: add a redirect generation id in inetpeer

Sorry :(
