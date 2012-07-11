From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH 1/4] skbtrace: core feature
Date: Wed, 11 Jul 2012 08:32:03 +0200
Message-ID: <1341988323.3265.6968.camel@edumazet-glaptop>
References: <4FFBC6B6.2000600@gmail.com>  <4FFCE241.6010305@gmail.com>
	 <1341979398.3265.6648.camel@edumazet-glaptop>  <4FFD1A0C.8090909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46243 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755892Ab2GKGcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:32:08 -0400
Received: by bkwj10 with SMTP id j10so740787bkw.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 23:32:07 -0700 (PDT)
In-Reply-To: <4FFD1A0C.8090909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 14:15 +0800, Li Yu wrote:
> =E4=BA=8E 2012=E5=B9=B407=E6=9C=8811=E6=97=A5 12:03, Eric Dumazet =E5=
=86=99=E9=81=93:

> > You said that some 'buggy' drivers set rxhash to zero, but its a va=
lid
> > operation.
> >
> > You said 'it seems that RPS hashing can not work well for some corn=
er
> > cases', but its a known fact.
> >
>=20
> Em, we really are able to verify RPS imbalance by checking the last
> column of /proc/net/softnet_stat, but skbtrace can give us more detai=
ls
> of RSS/RPS hashing. For improper RPS hashing case, it can provide mor=
e
> details of what really happen in real time.

A hash is a hash. Its rarely perfect.

RPS is a best effort, and not suitable for all needs.

If you follow netdev, maybe you saw that I suggested to use a BPF to
compute the hash, for specialized needs.

Of course, RFS can also help right now.
