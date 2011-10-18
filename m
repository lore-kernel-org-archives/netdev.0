From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH v13 0/6] flexcan: Add support for powerpc flexcan
 (freescale p1010)
Date: Tue, 18 Oct 2011 04:43:28 -0500
Message-ID: <20111018094328.GC22814@sgi.com>
References: <1313551944-28603-1-git-send-email-holt@sgi.com>
 <16FBAA47-5133-43A1-80CE-C6D63B79FB5D@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robin Holt <holt@sgi.com>, "David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:57069 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753956Ab1JRJna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Oct 2011 05:43:30 -0400
Content-Disposition: inline
In-Reply-To: <16FBAA47-5133-43A1-80CE-C6D63B79FB5D@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2011 at 12:44:07AM -0500, Kumar Gala wrote:
>=20
> On Aug 16, 2011, at 10:32 PM, Robin Holt wrote:
>=20
> > David,
> >=20
> > The following set of patches have been reviewed by the above partie=
s and
> > all comments have been integrated.  Although the patches stray from=
 the
> > drivers/net/can directory, the diversions are related to changes fo=
r
> > the flexcan driver.
> >=20
> > The patch set is based upon your net-next-2.6 tree's commit 6c37e46=
=2E
> >=20
> > Could you please queue these up for the next appropriate push to Li=
nus'
> > tree?
> >=20
> > Thanks,
> > Robin Holt
>=20
> Robin,
>=20
> Do you remember why we went with just 'fsl,p1010-flexcan' as the devi=
ce tree compatible?  Do we feel the flex can on P1010 isn't the same as=
 on MPC5xxx? or the ARM SoCs?

The decision was due to the fact there is no true "generic" fsl.flexcan
chip free of any SOC implementation and therefore not something which
could be separately defined.  That decision was made by Grant Likely.
I will inline that email below.

Robin


On Mon, Aug 15, 2011 at 09:13:50AM -0600, Grant Likely wrote:
> On Mon, Aug 15, 2011 at 9:03 AM, Robin Holt <holt@sgi.com> wrote:
> > Grant,
> >
> > Earlier, you had asked for a more specific name for the compatible
> > property of the Freescale flexcan device. =A0I still have not gotte=
n a
> > more specific answer. =A0Hopefully Marc can give you more details a=
bout
> > the flexcan implementations.
>=20
> If there is no ip core version, then just stick with the
> fsl,<soc>-flexcan name and drop "fsl,flexcan".  Marketing may say
> flexcan is flexcan, but hardware engineers like to change things.
> Trying to be too generic in compatible values will just lead to
> problems in the future.

Thanks,
Robin
