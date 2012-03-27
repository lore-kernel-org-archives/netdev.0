From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: bnx2x - bnx2x_credit_pool_get_entry bug?
Date: Tue, 27 Mar 2012 08:58:35 +0200
Message-ID: <1332831515.21698.2.camel@lb-tlvb-dmitry>
References: <CAHo-OozR_OginBaH3yhwgdQBwxpcqfjakpBC-pOCQO8Bp2vM4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Linux NetDev" <netdev@vger.kernel.org>,
	"Maciej =?UTF-8?Q?=C5=BBenczykowski?=" <maze@google.com>
To: "Maciej =?UTF-8?Q?=C5=BBenczykowski?=" <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3473 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664Ab2C0G67 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 02:58:59 -0400
In-Reply-To: <CAHo-OozR_OginBaH3yhwgdQBwxpcqfjakpBC-pOCQO8Bp2vM4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-26 at 22:14 -0700, Maciej =C5=BBenczykowski wrote:

> looks to me like idx =3D vec * BNX2X_POOL_VEC_SIZE should actually be
> idx =3D vec * BIT_VEC64_ELEM_SZ
>=20

This is correct! Thank you, Maciej. The patch is coming ...
