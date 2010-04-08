From: David Miller <davem@davemloft.net>
Subject: Re: Crashes in xfrm_lookup
Date: Thu, 08 Apr 2010 11:28:00 -0700 (PDT)
Message-ID: <20100408.112800.123321518.davem@davemloft.net>
References: <20100408111441.GA14241@sirena.org.uk>
	<4BBDBCF9.5060906@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35868
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758895Ab0DHS15 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 14:27:57 -0400
In-Reply-To: <4BBDBCF9.5060906@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 08 Apr 2010 14:24:41 +0300

> Mark Brown wrote:
>> With -next as of today I'm experiencing crashes in the xfrm_lookup
>> code
>> when attempting to boot from an NFS root on a SMDK6410 (an ARM based
>> development board).  I'm currently investigating what's gone wrong,
>> but
>> thought it was better to report early in case it's obvious to someon=
e
>> familiar with the code or there's a fix already.
>=20
> Probably the same as http://marc.info/?t=3D127071006600005&r=3D1&w=3D=
2
>=20
> Happens because CONFIG_XFRM_SUB_POLICY is not enabled, and one of
> the helper functions I used did unexpected things in that case.
>=20
> Try the following:

Since this fix has been confirmed I'm applying it to net-next-2.6,
thanks!
