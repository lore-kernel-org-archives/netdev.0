From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 small patches for xfrm
Date: Fri, 1 Aug 2014 09:05:08 -0700
Message-ID: <20140801090508.384adbc1@haswell.linuxnetplumber.net>
References: <2141002.LfKmUBSlWz@ul001176>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jaroslav =?utf-8?B?xaBhZmth?= <jaroslav.safka@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36270 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754615AbaHAQFM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 12:05:12 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so6059074pab.29
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 09:05:11 -0700 (PDT)
In-Reply-To: <2141002.LfKmUBSlWz@ul001176>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 01 Aug 2014 13:16:09 +0200
Jaroslav =C5=A0afka <jaroslav.safka@tieto.com> wrote:

> Hi,
> I found the tool "ip xfrm" is not able to add "cipher_null" because t=
here is=20
> no possibility to set key with zero length.
>=20
> I solved it by this change:
>=20
> -       if (slen > 2 && strncmp(key, "0x", 2) =3D=3D 0) {
> +       if (slen >=3D 2 && strncmp(key, "0x", 2) =3D=3D 0) {
>=20
> By this change you can specify key as "0x" which will pass for key ex=
istence=20
> and set key len to 0.
>=20
> this patch is against version iproute2-3.14.0
>=20
> Second patch enable use proto ip. Because it is supported by kernel.
>=20
> Have a nice day :)
>=20
> Regards
> Jarek

Please format patches in same manner as kernel patches as described
in Documentation/SubmittingPatches.  One patch per email; email with [P=
ATCH]
in subject line; and please don't use attachments if possible.
