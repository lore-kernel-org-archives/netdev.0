From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 3/3] team: replicate options on register
Date: Thu, 17 Nov 2011 11:03:48 +0100
Message-ID: <1321524228.2751.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
	 <1321477749-1877-4-git-send-email-jpirko@redhat.com>
	 <1321518736.3274.45.camel@edumazet-laptop>
	 <20111117095729.GA2093@minipsycho>
	 <1321524023.2751.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:63210 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756237Ab1KQKDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 05:03:51 -0500
Received: by ggnb2 with SMTP id b2so818071ggn.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 02:03:51 -0800 (PST)
In-Reply-To: <1321524023.2751.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 11:00 +0100, Eric Dumazet a =C3=A9crit=
 :

> If you know the absolute limit of option_count, you could use
>=20
> struct team_option *dst_opts[OPTION_COUNT_MAX];
>=20
> If not, then a kmalloc()/kfree() is probably needed ;)
>=20
>=20

Sorry, forgot to include the link explaining Linus opinion on
variable-length arrays

https://lkml.org/lkml/2011/10/23/25
