From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis
 purpose.
Date: Sun, 20 Mar 2011 10:18:30 +0100
Message-ID: <1300612710.2831.106.camel@edumazet-laptop>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	 <1300351330.10164.712.camel@edumazet-laptop>
	 <AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	 <20110317142030.62af785a@nehalam>
	 <AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
	 <1300428324.2881.5.camel@edumazet-laptop>
	 <AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
	 <1300510960.2831.2.camel@edumazet-laptop>
	 <AANLkTimsoF+khCfU2aEQNoJ0DBf_p9-v+Zim0X5RrLpw@mail.gmail.com>
	 <1300514604.2831.23.camel@edumazet-laptop>
	 <AANLkTikyoS-YDH+N92yCXiFg7MfXhSHeudND9VJgAp15@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50389 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616Ab1CTJSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 05:18:35 -0400
Received: by wwa36 with SMTP id 36so6353097wwa.1
        for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 02:18:34 -0700 (PDT)
In-Reply-To: <AANLkTikyoS-YDH+N92yCXiFg7MfXhSHeudND9VJgAp15@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 20 mars 2011 =C3=A0 00:30 -0700, Jerry Chu a =C3=A9crit :

> I presume the filtering of specific IP addrs/ports are done in the
> kernel to short-circuit the
> O(n) loop. Otherwise it seems moot (i.e., it still costs O(n)).
>=20

=46iltering is done in kernel, and we can extend filtering capa if
necessary.

/proc/net/tcp is a flat file, you cannot do this


> A quick look at inet_csk_diag_dump() does not reveal anything like
> that. But I haven't
> looked hard enough.

You should ;)


