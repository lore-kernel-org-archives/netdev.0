From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] caif: fix endian conversion in cffrml_transmit()
Date: Mon, 21 Nov 2011 16:46:43 -0500 (EST)
Message-ID: <20111121.164643.58544532996822474.davem@davemloft.net>
References: <20111121063356.GH2203@ZenIV.linux.org.uk>
	<20111121195056.GM29436@mwanda>
	<CAJK669bL51Ct-Q9LxXwFdiaQAnfkx2Um1k0Cutci2z6mdd2THw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dan.carpenter@oracle.com, viro@zeniv.linux.org.uk,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: sjurbren@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755077Ab1KUVqt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 16:46:49 -0500
In-Reply-To: <CAJK669bL51Ct-Q9LxXwFdiaQAnfkx2Um1k0Cutci2z6mdd2THw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjurbren@gmail.com>
Date: Mon, 21 Nov 2011 22:20:09 +0100

>> The "tmp" variable here is used to store the result of cpu_to_le16()
>> so it should be an __le16 instead of an int. =A0We want the high bit=
s
>> set and the current code works on little endian systems but not on
>> big endian systems.
>>
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> ---
>> v2: =A0In v1 I used a u16 instead of an __le16. =A0Also I've changed=
 the
>> name to "data" instead of "tmp".
>=20
> Thanks Dan, good catch - this would have failed badly on a b_e archit=
ecture.
>=20
> Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied, thanks guys.
