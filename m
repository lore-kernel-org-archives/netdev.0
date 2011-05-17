From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: sfc: an enumeration is not a bitmask
Date: Tue, 17 May 2011 19:18:39 +0100
Message-ID: <1305656319.2848.28.camel@bwh-desktop>
References: <20110517.141446.140687548350861625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45139 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756015Ab1EQSSm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 14:18:42 -0400
In-Reply-To: <20110517.141446.140687548350861625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 14:14 -0400, David Miller wrote:
> Ben can you please get rid of "enum efx_fc_type"?
>=20
> drivers/net/sfc/mcdi_mac.c: In function =E2=80=98efx_mcdi_set_mac=E2=80=
=99:
> drivers/net/sfc/mcdi_mac.c:36:2: warning: case value =E2=80=983=E2=80=
=99 not in enumerated type =E2=80=98enum efx_fc_type=E2=80=99
>=20
> An enumeration is not a bitmask, instead it means one out of the set
> of enumerated values will be used.  This means that the warning
> here about:
>=20
> 	switch (efx->wanted_fc) {
> 	case EFX_FC_RX | EFX_FC_TX:
>=20
> is completely legitimate.

I think this is common practice in C.  I filed a bug regarding the
warning at <http://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D46457>, which
has not yet been resolved either way.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

