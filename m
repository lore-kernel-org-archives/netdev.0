From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tc: add missing limits.h header
Date: Thu, 29 Dec 2016 10:44:58 -0800
Message-ID: <20161229104458.5811b245@xeon-e3>
References: <c18609c5d906bbba8176138cfafd88c4a38c8190.1482432767.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34102 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753106AbcL2SpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 13:45:01 -0500
Received: by mail-pg0-f52.google.com with SMTP id y62so117045543pgy.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 10:45:01 -0800 (PST)
In-Reply-To: <c18609c5d906bbba8176138cfafd88c4a38c8190.1482432767.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Dec 2016 20:52:48 +0200
Baruch Siach <baruch@tkos.co.il> wrote:

> This fixes under musl build issues like:
>=20
> f_matchall.c: In function =E2=80=98matchall_parse_opt=E2=80=99:
> f_matchall.c:48:12: error: =E2=80=98LONG_MIN=E2=80=99 undeclared (first u=
se in this function)
>    if (h =3D=3D LONG_MIN || h =3D=3D LONG_MAX) {
>             ^
> f_matchall.c:48:12: note: each undeclared identifier is reported only onc=
e for each function it appears in
> f_matchall.c:48:29: error: =E2=80=98LONG_MAX=E2=80=99 undeclared (first u=
se in this function)
>    if (h =3D=3D LONG_MIN || h =3D=3D LONG_MAX) {
>                              ^
>=20
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Sure, applied
