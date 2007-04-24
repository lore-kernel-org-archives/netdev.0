From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Tue, 24 Apr 2007 15:29:49 -0700
Message-ID: <20070424152949.367bd20c@dxpl.pdx.osdl.net>
References: <20070425.011028.113320997.yoshfuji@linux-ipv6.org>
	<20070424183827.adb60ae0.dada1@cosmosbay.com>
	<20070424100420.2860db68@dxpl.pdx.osdl.net>
	<20070425.065539.104129657.yoshfuji@linux-ipv6.org>
	<20070424145754.1a37f666@dxpl.pdx.osdl.net>
	<462E80D6.8060609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, bunk@stusta.de, davem@davemloft.net,
	netdev@vger.kernel.org, tglx@linutronix.de
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:44023 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423166AbXDXWdD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 18:33:03 -0400
In-Reply-To: <462E80D6.8060609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Apr 2007 00:12:38 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > On Wed, 25 Apr 2007 06:55:39 +0900 (JST)
> > YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E  <yoshfuji=
@linux-ipv6.org> wrote:
> >=20
> >> In article <20070424100420.2860db68@dxpl.pdx.osdl.net> (at Tue, 24=
 Apr 2007 10:04:20 -0700), Stephen Hemminger <shemminger@linux-foundati=
on.org> says:
> >>
> >>> Yoshifuji-san had the right idea, but ktime_to_us needs to be def=
ined
> >>> in a way that works on both 64 and 32bit platforms.
> >> No, this does not cure.
> >>> =20
> >>> +#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
> >>> +
> >> NSEC_PER_USEC?
> >=20
> > On 64 bit platforms, ktime stores nano-seconds in a 64 bit value, s=
o
> > this is correct.
>=20
> Really ? You introduce a 10^6 error and say it's correct ?
>=20
> We believe the correct divisor is 10^3 to get usec from nsec, not 10^=
9
>=20
Uh, whimper, your right
