From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/5] NET Improve layering of structs dst_entry/rtable/rt6_info/dn_route
 to get less dcache footprint
Date: Sat, 10 Feb 2007 09:17:02 +0100
Message-ID: <45CD7F7E.3010102@cosmosbay.com>
References: <20070208093935.90CA.SHINTA@sfc.wide.ad.jp>	<20070207.165213.98418769.davem@davemloft.net>	<45CB96DA.20400@cosmosbay.com> <20070209.173124.78709988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:52053 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbXBJIRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 03:17:19 -0500
In-Reply-To: <20070209.173124.78709988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 08 Feb 2007 22:32:10 +0100
>=20
>> I prepared the following five patches :
>>
>> [PATCH 1/5] : Introduce union in struct dst_entry, to prepare patche=
s 2,3,4
>> [PATCH 2/5] : Convert ipv4 route to use the new dst_entry 'next' poi=
nter
>> [PATCH 3/5] : Convert ipv6 route to use the new dst_entry 'next' poi=
nter
>> [PATCH 4/5] : Convert decnet route to use the new dst_entry 'next' p=
ointer
>> [PATCH 5/5] : Reorder fields of struct dst_entry
>=20
> I've applied all of this, and fixed up the changelog description
> of patch #4 as-needed :-)
>=20
> Thanks a lot Eric.

I was about to correct this stuff this saturday morning, so *many* than=
ks to=20
you David, I can start my week end like normal guys :)

