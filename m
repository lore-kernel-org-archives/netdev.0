From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] cls_rsvp.h was outdated
Date: Tue, 30 Aug 2011 13:38:25 +0200
Message-ID: <1314704305.2935.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <0f79c88be72b75d0526d3f3c2ebf826b.squirrel@kondor.etf.bg.ac.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44927 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898Ab1H3LiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 07:38:25 -0400
In-Reply-To: <0f79c88be72b75d0526d3f3c2ebf826b.squirrel@kondor.etf.bg.ac.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 13:11 +0200, "Igor Maravi=C4=87" a =C3=
=A9crit :
> File cls_rsvp.h in /net/sched was outdated. I'm sending you patch for=
 this
> file.
> Patch was done against Linux 2.6.38-8
>=20
> Signed-off-by: Igor Maravi=C4=87 <igorm@etf.rs>
>=20
> --- linux-2.6.38.8/net/sched/cls_rsvp.h.orig	2011-08-30 12:46:42.6634=
43918
> +0200

Two last points :

1) Your mail client added line wraps, please take a look at
Documentation/email-clients.txt


>=20
>  static struct tcf_proto_ops RSVP_OPS =3D {
> -	.next		=3D	NULL,
> +	//.next		=3D	NULL,
>  	.kind		=3D	RSVP_ID,
>  	.classify	=3D	rsvp_classify,
>  	.init		=3D	rsvp_init,
>=20

2) Dont add // comments, just remove the line.

You also could add __read_mostly here :

static struct tcf_proto_ops RSVP_OPS __read_mostly =3D {


Thanks
