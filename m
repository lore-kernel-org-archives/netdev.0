From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH] Age Entry For IPv4 Route Table
Date: Mon, 25 Jun 2007 10:51:39 +0530
Message-ID: <467F50E3.2050405@linux.vnet.ibm.com>
References: <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com> <20070625.141451.21870598.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	varuncha@in.ibm.com
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:47248 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbXFYFVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 01:21:51 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5P5Louj029008
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 01:21:50 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5P5LoLC267012
	for <netdev@vger.kernel.org>; Sun, 24 Jun 2007 23:21:50 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5P5LnJX017260
	for <netdev@vger.kernel.org>; Sun, 24 Jun 2007 23:21:50 -0600
In-Reply-To: <20070625.141451.21870598.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com> (at Mo=
n, 25 Jun 2007 10:28:38 +0530), Varun Chandramohan <varunc@linux.vnet.i=
bm.com> says:
>
>  =20
>> According to the RFC 4292 (IP Forwarding Table MIB) there is a need =
for an age entry for all the routes in the routing table. The entry in =
the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
>> Many snmp application require this age entry. So iam adding the age =
field in the routing table and providing
>> the interface for this value via /proc/net/route.
>>    =20
>
> I'm not in favor of adding new field(s) to /proc/net/route.
>
>  =20
Do you think it will break any user level functionality? I have tested
with netstat, route and net-snmp which reads from the same /proc
interface. They seem to work fine.
> --yoshfuji
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  =20

