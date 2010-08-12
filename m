From: Ulrich Weber <uweber@astaro.com>
Subject: Re: Latest iproute2 breaks "ip route get" command
Date: Thu, 12 Aug 2010 11:02:34 +0200
Message-ID: <4C63B8AA.40101@astaro.com>
References: <20100808193304.GA15380@amd64.fatal.se>	 <AANLkTim4h7rTJuF7UWAE-p_4NGkrwksUjoK6m2x5BubG@mail.gmail.com> <1281297165.4116.19.camel@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Comolli <fabio.comolli@gmail.com>, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-65.dex002.intermedia.net ([64.78.20.23]:9002 "EHLO
	DHOST002-65.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751660Ab0HLJCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 05:02:38 -0400
In-Reply-To: <1281297165.4116.19.camel@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

your fix will work for IPv4 but will display the IPv6 cached routes
again with "ip -6 route show" what I was trying to fix with
447928279c88b6581ae4cdc1b5ac0a9e755aff64

Will send another patch which makes the filter.cloned check not matchin=
g
for iproute_get routes.

Best regards
 Ulrich

On 08/08/2010 09:52 PM, Andreas Henriksson wrote:
> On s=C3=B6n, 2010-08-08 at 21:31 +0200, Fabio Comolli wrote:
>> Yup, that seems to fix it.
>> You can add my Tested-By in case you need it.
>=20
> I'll let Ulrich Weber confirm it's the right fix and forward to Steph=
en
> Hemminger. Just received an "out of office" notice saying he'll be ba=
ck
> 11 august (wednesday), so I guess we'll have to wait a couple of days
> for that.
>=20
> //Andreas
>=20


--=20
Ulrich Weber | uweber@astaro.com | Software Engineer
Astaro GmbH & Co. KG | www.astaro.com | Phone +49-721-25516-0 | Fax =E2=
=80=93200
An der RaumFabrik 33a | 76227 Karlsruhe | Germany
