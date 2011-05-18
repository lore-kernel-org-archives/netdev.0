From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PATCH] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 16:42:42 +0200
Message-ID: <1305729762.2991.34.camel@edumazet-laptop>
References: <BANLkTimWpmFj1gx=XvvoXFVxL9q927iWfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Vladislav Yasevich <vladislav.yasevich@hp.com>
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49823 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757254Ab1EROmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 10:42:45 -0400
Received: by fxm17 with SMTP id 17so1255744fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 07:42:44 -0700 (PDT)
In-Reply-To: <BANLkTimWpmFj1gx=XvvoXFVxL9q927iWfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 16:36 +0200, Jacek Luczak a =C3=A9crit :

> ---
>  net/sctp/bind_addr.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index faf71d1..6150ac5 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
> *bp, __u16 port)
>  /* Dispose of the address list. */

I am afraid your mailer mangled the patch.

You should have only one line :

@@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr *b=
p, __u16 port)

Instead, there is a line wrap :

@@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
*bp, __u16 port)



