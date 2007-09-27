From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: sky2 FE+ receive status workaround
Date: Thu, 27 Sep 2007 06:58:07 -0700
Message-ID: <20070927065807.7a71ae89@freepuppy.rosehill>
References: <20070926175847.706025d0@freepuppy.rosehill>
	<4C6E8545-ADDC-456E-B17B-B3512A6047D1@seehuhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jochen =?UTF-8?B?Vm/Dnw==?= <voss@seehuhn.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34862 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754224AbXI0ODn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 10:03:43 -0400
In-Reply-To: <4C6E8545-ADDC-456E-B17B-B3512A6047D1@seehuhn.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Sep 2007 09:14:11 +0100
Jochen Vo=C3=9F <voss@seehuhn.de> wrote:

> Hi Stephen,
>=20
> On 27 Sep 2007, at 01:58, Stephen Hemminger wrote:
> > +	/* This chip has hardware problems that generates bogus status.
> > +	 * So do only marginal checking and expect higher level protocols
> > +	 * to handle crap frames.
> > +	 */
> > +	if (sky2->hw->chip_id =3D=3D CHIP_ID_YUKON_FE_P &&
> > +	    sky2->hw->chip_rev =3D=3D CHIP_REV_YU_FE2_A0 &&
> > +	    length !=3D count)
> > +		goto okay;
>=20
> Shouldn't the condition be "length =3D=3D count"?
>=20

No, the code is correct as is.  Basically if length =3D=3D count, then
the status field is correct, and the driver can go ahead and use it.
If length !=3D count, then the status is bogus but the data is okay.


--=20
Stephen Hemminger <shemminger@linux-foundation.org>
