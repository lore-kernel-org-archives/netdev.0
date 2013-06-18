From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: restore ethtool ABI to control VLAN hardware
 acceleration
Date: Mon, 17 Jun 2013 17:10:01 -0700 (PDT)
Message-ID: <20130617.171001.1255646251913428917.davem@davemloft.net>
References: <1371436083.7579.1.camel@nexus>
	<1371493254.2086.64.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fernando_b1@lab.ntt.co.jp, kaber@trash.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3FRAKE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:10:04 -0400
In-Reply-To: <1371493254.2086.64.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 17 Jun 2013 19:20:54 +0100

> On Mon, 2013-06-17 at 11:28 +0900, Fernando Luis V=E1zquez Cao wrote:
>> As part of the push to add 802.1ad server provider tagging support t=
o the
>> kernel the VLAN features flags were renamed. Unfortunately the kerne=
l name
>> for the VLAN hardware acceleration features that the kernel shows us=
er space
>> was included in the rename, which broke ethtool (txvlan and rxvlan o=
ptions
>> do not work).
>=20
> I expected something like that and said this was an ABI change, but
> apparently my objection wasn't sufficient.
>=20
>> This patch restores the original names, i.e. the original ABI.
>> If we wanted to make clear to users that we are refering to CTAGs we=
 can
>> always change ethtool's short_name and long_name for these features =
(for
>> example something along the lines of txvlan -> txvlan-ctag, tx-vlan-=
offload ->
>> tx-vlan-ctag-offload).
>>=20
>> Cc: Patrick McHardy <kaber@trash.net>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
>=20
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ok Ben you were indeed right :-)

Applied, thanks.
