From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bpf_jit_compile issues on x86_64
Date: Wed, 18 Jan 2012 08:30:35 +0100
Message-ID: <1326871835.2606.40.camel@edumazet-laptop>
References: <20120118022709.GA4167@linuxace.com>
	 <1326867428.2606.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44370 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380Ab2ARHak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 02:30:40 -0500
Received: by werb13 with SMTP id b13so147035wer.19
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 23:30:38 -0800 (PST)
In-Reply-To: <1326867428.2606.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 07:17 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le mardi 17 janvier 2012 =C3=A0 18:27 -0800, Phil Oester a =C3=A9crit=
 :
> > On a 3.1.8 kernel, I've had a few snort boxes panic when using the =
new bpf_jit
> > code.  Setting bpf_jit_enable back to 0 solves the problem.  Below =
is the
> > warning, followed by the panic.  I've checked the current Linus tre=
e, but
> > other than a03ffcf8 (which exists in 3.1.8) I don't see anything ne=
w in this
> > area.  Any ideas?  Eric?
> >=20
>=20
> Hi Phil, thanks for the report !
>=20
> Any chance you could send me the bpf filter that was loaded at this
> time ?
>=20

Hmm, I found the bug, I'll send a cumulative patch in following hours.

Thanks again
