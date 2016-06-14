From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Macro definition for SFF-8436/8636
 Memory map max sizes
Date: Tue, 14 Jun 2016 15:29:42 -0400 (EDT)
Message-ID: <20160614.152942.1686747827169238570.davem@davemloft.net>
References: <CAKWE-Xrw6kE7-rSOP1NRQaT3jAHWVVkhWz8c2oinYmQc+LrnjQ@mail.gmail.com>
	<20160611.192648.91885921700006865.davem@davemloft.net>
	<1465734852.3529.148.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vidya@cumulusnetworks.com, bwh@kernel.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbcFNT3o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 15:29:44 -0400
In-Reply-To: <1465734852.3529.148.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 12 Jun 2016 13:34:12 +0100

> On Sat, 2016-06-11 at 19:26 -0700, David Miller wrote:
>> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>> Date: Sat, 11 Jun 2016 16:22:38 -0700
>>=20
>> > As part of ethtool application, application is requesting=A0 the d=
rivers
>> > to provide the supported eeprom size to allocate memory buffer for
>> > getting complete dump.
>>=20
>> And the right way to do that is the driver requests the eeprom info
>> with a buffer size of zero, then the driver fills in the size field
>> for what the size actually is.
>>=20
>> Then the application can allocate the proper buffer size and rerun
>> the eeprom request.
>>=20
>> Putting endless values for each and every eeprom type a device has i=
s
>> just rediculous.
>>=20
>> I'm not going to continue promoting this broken and unscalable schem=
e,
>> we have to fix this.
>=20
> I don't think there's nothing broken here. =A0ethtool doesn't use tho=
se
> macros, the drivers do.

If it's a value only for the drivers, then why does it need to be in a
public UAPI header file and exported outside of the kernel at all?

If it's a private driver detail, it should live in the driver.
