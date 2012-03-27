From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: bnx2x - bnx2x_credit_pool_get_entry bug?
Date: Tue, 27 Mar 2012 15:55:18 -0700
Message-ID: <CANP3RGdBemOaV1yQVefo31t2ZzDeXjbNzZn26zAGZ8_5LNo0MA@mail.gmail.com>
References: <CAHo-OozR_OginBaH3yhwgdQBwxpcqfjakpBC-pOCQO8Bp2vM4g@mail.gmail.com>
	<1332831515.21698.2.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36490 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756840Ab2C0WzT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 18:55:19 -0400
Received: by iagz16 with SMTP id z16so533383iag.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 15:55:19 -0700 (PDT)
In-Reply-To: <1332831515.21698.2.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 11:58 PM, Dmitry Kravkov <dmitry@broadcom.com> =
wrote:
> On Mon, 2012-03-26 at 22:14 -0700, Maciej =C5=BBenczykowski wrote:
>
>> looks to me like idx =3D vec * BNX2X_POOL_VEC_SIZE should actually b=
e
>> idx =3D vec * BIT_VEC64_ELEM_SZ
>>
>
> This is correct! Thank you, Maciej. The patch is coming ...

Thanks.

--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
1600 Amphitheatre Parkway, Mountain View, CA 94043
tel: +1 (650) 253-0062
