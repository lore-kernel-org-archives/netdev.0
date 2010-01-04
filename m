From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Mon, 04 Jan 2010 15:50:22 +0100
Message-ID: <878wcdx6tt.fsf@nemi.mork.no>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	<1261604906.609.106.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:49986 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459Ab0ADOxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 09:53:12 -0500
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1NRoIM-0005qY-DF
	for netdev@vger.kernel.org; Mon, 04 Jan 2010 15:52:34 +0100
Received: from 193.160.199.2 ([193.160.199.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2010 15:52:34 +0100
Received: from bjorn by 193.160.199.2 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2010 15:52:34 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann <marcel@holtmann.org> writes:

>> This patch adds the Sony Ericsson J105i (Naite)
>> mobile phone to the cdc_ether device whitelist,
>> enabling access to the modem.
>>=20
>> I would think more SE models of this generation
>> (2009Q3) with builtin HSDPA modules also needs
>> to be added to this list.
>
> I do prefer if we NOT use the mbm_info details for this since they ar=
e
> clearly for mobile broadband cards with FLAG_WWAN.

Assuming that these devices can be configured just like the WWAN cards
by sending commands to the associated ACM* or WDM* interfaces, why woul=
d
you treat them differently?  Because they've got a keyboard and a
display?

> Since this is a phone where the setup of the connection is done via t=
he
> phone. And you just treat this as an Ethernet device and run DHCP, th=
en
> please create a se_info or similar with FLAG_ETHER.

Why would anyone want to setup the connection via the phone?  That seem=
s
unnecessary cumbersome. I'd prefer such devices to be auto-configured
just like any other WWAN device.


Bj=C3=B8rn

