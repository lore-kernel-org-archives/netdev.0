From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: Fix warnings with gcc 4.9 and clang 3.4
Date: Mon, 10 Mar 2014 13:25:40 -0700
Message-ID: <20140310132540.6123548b@nehalam.linuxnetplumber.net>
References: <284875ac93e0904c42a436cbf05cc57d@mail.lindev.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Bernhard =?ISO-8859-1?B?Um9zZW5rcuRuemVy?= <bero@lindev.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:57457 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbaCJUZo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:25:44 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl14so7752785pab.4
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 13:25:43 -0700 (PDT)
In-Reply-To: <284875ac93e0904c42a436cbf05cc57d@mail.lindev.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Mar 2014 03:00:53 +0100
Bernhard Rosenkr=E4nzer <bero@lindev.ch> wrote:

> Hi,
> the latest compilers (gcc 4.9 and clang 3.4) issue warnings when doin=
g=20
> an incomplete struct initialization (e.g. "struct tc_sizespec s =3D=20
> {0};").
>=20
> Since many people like to compile lower level bits and pieces with=20
> -Werror, this should probably be fixed. Patch attached.
>=20
> ttyl
> bero

Does not apply to current source, please update:
