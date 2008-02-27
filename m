From: "Wappler Marcel" <Marcel.Wappler@bridgeco.net>
Subject: RE: [PATCH] [resend]The kernel gets no IP from some DHCP servers, 2.6.24
Date: Wed, 27 Feb 2008 14:11:55 +0100
Message-ID: <83116F0A4FF67A4F97BA0B6E408C48E301C5CE08@zuerich.BC-Int.NET>
References: <83116F0A4FF67A4F97BA0B6E408C48E301C5CDEF@zuerich.BC-Int.NET> <47C55BBF.7080501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <ebiederman@lnxi.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.bridgeco.net ([213.173.191.47]:2612 "EHLO mx.bridgeco.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755586AbYB0NL7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 08:11:59 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47C55BBF.7080501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original Message-----
>>  #include <linux/types.h>
>> @@ -103,6 +107,7 @@
>>  					   - '3' from resolv.h */
>> =20
>>  #define NONE __constant_htonl(INADDR_NONE)
>> +#define ZERO __constant_htonl(((unsigned long int) 0x00000000))
>This should probably use INADDR_ANY.
My first try went in this direction. But at a second look I thought
that the names ANY (255.255.255.255) and NONE (0.0.0.0) are indirect
leading to confusion. The interpretation of the zero addresses in
the DHCPDISCOVER packet is in the kind of 'no address' and not of
'any addressee'. So the meaning and usage of INADDR_ANY and ZERO
may be totally different in this file.
In my opinion it is necessary to distinguish between INADDR_ANY
and the ZERO address which ist requested to be in the DHCPDISCOVER
packet.

Marcel
--
Marcel Wappler
Bridgeco AG
CH-8600 D=FCbendorf
Switzerland
