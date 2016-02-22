From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 2/3] lan78xx: add ethtool set & get pause
 functions
Date: Mon, 22 Feb 2016 14:10:14 -0500 (EST)
Message-ID: <20160222.141014.1517836822587262524.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D404B37B5@CHN-SV-EXMX02.mchp-main.com>
	<1455839111.2794.51.camel@decadent.org.uk>
	<9235D6609DB808459E95D78E17F2E43D404B55D1@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbcBVTKS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 14:10:18 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404B55D1@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: <Woojung.Huh@microchip.com>
Date: Mon, 22 Feb 2016 18:28:18 +0000

>> This is incorrect; you should always return the manual settings
>> (fc_request_control flags) here. =A0If autonegotiation is enabled th=
en
>> your get_settings function will return the actual pause flags.
>>=20
> What do you mean "return actual pause flags" when autoneg is enabled?
> Pause flags set by (or default) advertise flag?

It means what was negotiated by autonegotiation, and is actually in use=
=2E

Otherwise, how can the user find out what was negotiated?
