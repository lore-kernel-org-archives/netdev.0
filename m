From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Fri, 9 Nov 2012 15:08:33 +0000
Message-ID: <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
	 <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <footplus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33830 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753527Ab2KIPIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 10:08:36 -0500
In-Reply-To: <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 01:39 +0100, Aur=C3=A9lien wrote:
> On Wed, Nov 7, 2012 at 8:58 PM, Ben Hutchings <bhutchings@solarflare.=
com> wrote:
> > On Wed, 2012-11-07 at 13:27 +0100, Aur=C3=A9lien wrote:
> >
> > We just added the ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPROM
> > interface for this purpose.  The diagnostics obviously aren't reall=
y an
> > EEPROM but I don't think that matters.
> >
> > These drivers should report a type of ETH_MODULE_SFF_8472 (assuming=
 a
> > module is present) and expose an 'EEPROM' with the real EEPROM in t=
he
> > first 256 bytes and the diagnostic registers in the next 256 bytes.
> >
> > Decoding of the diagnostic registers can be done in ethtool itself.
> >
>=20
> Hi Ben,
>=20
> Thanks for this reply.
>=20
> I did not see these interfaces in my searches, but from what I gather
> from the code, the missing part is the actual decoding of the data in
> ethtool.
[...]

No, the driver also needs to implement ethtool_ops::get_module_info and
ethtool_ops::get_module_eeprom.  But those should be quite easy to do.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
