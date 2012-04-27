From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: cleanups in sock_setsockopt()
Date: Fri, 27 Apr 2012 08:02:20 +0200
Message-ID: <1335506540.2775.75.camel@edumazet-glaptop>
References: <1335505319.2775.72.camel@edumazet-glaptop>
	 <20120427.014848.764959411706970704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:44802 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755948Ab2D0GCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 02:02:25 -0400
Received: by wibhq7 with SMTP id hq7so272227wib.1
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 23:02:24 -0700 (PDT)
In-Reply-To: <20120427.014848.764959411706970704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 01:48 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 27 Apr 2012 07:41:59 +0200
>=20
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > Use min()/max() macros, reformat two comments, use !!test_bit() to
> > match !!sock_flag()
> >=20
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>=20
> Introduces warnings:
>=20
> net/core/sock.c: In function =E2=80=98sock_setsockopt=E2=80=99:
> net/core/sock.c:584:9: warning: comparison of distinct pointer types =
lacks a cast [enabled by default]
> net/core/sock.c:605:9: warning: comparison of distinct pointer types =
lacks a cast [enabled by default]
> net/core/sock.c:623:19: warning: comparison of distinct pointer types=
 lacks a cast [enabled by default]
>=20
> and that makes sense since int is signed and __u32 is not.
>=20
> Your compiler didn't spit that out too?

Hmm... I wonder how I missed these...

I'll fix this, thanks
