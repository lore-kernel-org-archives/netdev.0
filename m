From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH] net: rds: Don't allocate rds_sock on stack
Date: Wed, 27 Aug 2014 11:46:51 +0100
Message-ID: <20140827104651.GZ17528@sirena.org.uk>
References: <1408926755-12277-1-git-send-email-broonie@kernel.org>
 <20140825.125740.214306460002405867.davem@davemloft.net>
 <20140826065409.GT17528@sirena.org.uk>
 <20140826.082906.614050508596912545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GeRqtehoFQsAE/S4"
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:35812 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932765AbaH0KrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 06:47:10 -0400
Content-Disposition: inline
In-Reply-To: <20140826.082906.614050508596912545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GeRqtehoFQsAE/S4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 26, 2014 at 08:29:06AM -0700, David Miller wrote:
> From: Mark Brown <broonie@kernel.org>

> > I agree that the existing code looks like it could be improved even more
> > but please bear in mind that I'm just looking for a clean build (we've
> > got less than 20 warnings in allmodconfig including staging at the
> > minute) rather than actively working on this code in particular - I've
> > no ability to do more than build testing here.

> I understand that, but please fix this bug properly.

Please set the expectation among the networking developers that their
code should compile cleanly on all architectures; currently the
networking code (mostly drivers rather than the core) is the single
biggest source of warnings outside of staging and if we are requring
things like this then that presents a substantial barrier to others
contributing to addressing the warnings.

--GeRqtehoFQsAE/S4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJT/bcXAAoJELSic+t+oim9fu8P/23ywCVBS+8XvxUSEX1Oqm1M
1MVisRWE6caLck0EZTu8pIcRQTlKNf2dqCg5h9MjOU+oDuLJqGzMo4gGrgXFdVpn
VUvpDgsWsMEDWMjBoNOpd/CQ63gkMtsgLPD7iJinYQlMRdq0X9/MppkkU+3GU/Aa
FKAbGkGJV1jH3ZWq6DmGDnTr6AFHCfzd+/zo5pCmG9SEjErh2Z7fz9N5jmmlMD0Z
Pox1topDyI5l6R1zAL61WOvBLav3VkB1LX3pYJpiVg95TiqU771fPWO63xIovUxM
1InqIu+ptjyKKn3yd1RB8RNv+hB8yNbMobZb9niqLSaLyzwIX2Q7Vm4sonX7aocL
vEYjtdLLYjCm1NAfpAAyIFZYEgnMJmBf6q7H+mDeb0lt3s4P+3f3EOD48tuHn6oa
6umfw50fPSYKkaqVlsZ+4/1KSMzIUWuflWuT/IKnbCYx++c+UkS5kvFQDHEhc3Yg
J6YYvZ/7pJ390Ffx92dP5q/sSAzW6dbKGLPUZrsqPMJ7H4v9H/hJKkFm4TptPAEZ
vb4NymkYDg35wO93sP0vCNlECWk5baL0afC9qgByrNaklN32mXiMiCdXqCQV2sIi
T5CkYUZjm7n2rt7smmmwm60UeSMDE394dpOIyOtuZviL6EUYD65hNzbp/E0jwOIu
ARSRi7plsPKPI9lokHAW
=kRVo
-----END PGP SIGNATURE-----

--GeRqtehoFQsAE/S4--
