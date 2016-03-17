From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Set cmd field in
 ETHTOOL_GLINKSETTINGS response to wrong nwords
Date: Wed, 16 Mar 2016 20:16:47 -0400 (EDT)
Message-ID: <20160316.201647.156083693171887111.davem@davemloft.net>
References: <20160314010537.GD21187@decadent.org.uk>
	<20160316.192638.370528273688631022.davem@davemloft.net>
	<1458171392.31907.39.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbcCQAQt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 20:16:49 -0400
In-Reply-To: <1458171392.31907.39.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 16 Mar 2016 23:36:32 +0000

> On Wed, 2016-03-16 at 19:26 -0400, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Mon, 14 Mar 2016 01:05:38 +0000
>>=20
>> > When the ETHTOOL_GLINKSETTINGS implementation finds that userland =
is
>> > using the wrong number of words of link mode bitmaps (or is trying=
 to
>> > find out the right numbers) it sets the cmd field to 0 in the resp=
onse
>> > structure.
>> >=A0
>> > This is inconsistent with the implementation of every other ethtoo=
l
>> > command, so let's remove that inconsistency before it gets into a
>> > stable release.
>> >=A0
>> > Fixes: 3f1ac7a700d03 ("net: ethtool: add new ETHTOOL_xLINKSETTINGS=
 API")
>> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>>=20
>> Applied and queued up for -stable, thanks Ben.
>=20
> This doesn't need fixing in any stable release.

My bad I thought it was needed for 4.5-final.
