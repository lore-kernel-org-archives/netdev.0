From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 10:55:09 +0200
Message-ID: <1273222509.2261.27.camel@edumazet-laptop>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
	 <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
	 <20100504091215.5a4a51f4@nehalam>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273147586.2357.63.camel@edumazet-laptop>
	 <70125082-4A0B-4E54-A7F6-B6CDC0375E78@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bhaskar Dutta <bhaskie@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lars Eggert <lars.eggert@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:60700 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351Ab0EGIzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 04:55:13 -0400
Received: by bwz19 with SMTP id 19so439428bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 01:55:11 -0700 (PDT)
In-Reply-To: <70125082-4A0B-4E54-A7F6-B6CDC0375E78@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 11:46 +0300, Lars Eggert a =C3=A9crit :
> On 2010-5-6, at 15:06, Eric Dumazet wrote:
> > This code should be completely rewritten for linux-2.6.35, its very=
 ugly
> > and over complex, yet it is not scalable.
>=20
> Let me quickly point out that the IETF has recently replaced TCP-MD5 =
with TCP-AO (http://tools.ietf.org/html/draft-ietf-tcpm-tcp-auth-opt-11=
) which is days or weeks away from being published as an RFC. (The draf=
t has been approved and it waiting for the RFC Editor to finish the fin=
al copy-editing.)
>=20
> You'll obviously still want TCP-MD5 support for talking to existing e=
quipment, but significant cycles would IMO be better spent on TCP-AO.
>=20

Thanks for this info !


