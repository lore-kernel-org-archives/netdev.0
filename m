From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] [PKT_SCHED] RED: Fix overflow in calculation of
 queue average
Date: Fri, 04 Aug 2006 16:36:28 -0700 (PDT)
Message-ID: <20060804.163628.126784309.davem@davemloft.net>
References: <11546408123792-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20060803184656.55da3939@localhost.localdomain>
	<Pine.LNX.4.58.0608041836490.8526@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56533
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422648AbWHDXgW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 19:36:22 -0400
To: ilpo.jarvinen@helsinki.fi
In-Reply-To: <Pine.LNX.4.58.0608041836490.8526@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 4 Aug 2006 18:44:20 +0300 (EEST)

> Overflow can occur very easily with 32 bits, e.g., with 1 second
> us_idle is approx. 2^20, which leaves only 11-Wlog bits for queue
> length. Since the EWMA exponent is typically around 9, queue
> lengths larger than 2^2 cause overflow. Whether the affected
> branch is taken when us_idle is as high as 1 second, depends on
> Scell_log, but with rather reasonable configuration Scell_log is
> large enough to cause p->Stab to have zero index, which always
> results zero shift (typically also few other small indices result
> in zero shift).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.
