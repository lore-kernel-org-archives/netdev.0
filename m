From: Thomas-Mich Richter <tmricht@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] iproute2 vxlan documentation update for ip command
Date: Fri, 05 Jul 2013 14:49:10 +0200
Message-ID: <51D6C0C6.7070600@linux.vnet.ibm.com>
References: <1373008131-8057-1-git-send-email-tmricht@linux.vnet.ibm.com> <1373008131-8057-2-git-send-email-tmricht@linux.vnet.ibm.com> <87siztju13.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:58814 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3GEMtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 08:49:17 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Fri, 5 Jul 2013 13:41:27 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id A1F1B2190023
	for <netdev@vger.kernel.org>; Fri,  5 Jul 2013 13:52:58 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r65Cn0Ja48889976
	for <netdev@vger.kernel.org>; Fri, 5 Jul 2013 12:49:00 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r65CnB6w018300
	for <netdev@vger.kernel.org>; Fri, 5 Jul 2013 08:49:11 -0400
In-Reply-To: <87siztju13.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2013 10:22 AM, Bj=C3=B8rn Mork wrote:
> Thomas Richter <tmricht@linux.vnet.ibm.com> writes:
>=20
>> The ip link command line help and the ip-link.8.in
>> man page are outdated in regards to the vxlan support.
>> The patch updates both the command line help for the
>> ip command and its man page.
>>
>> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
>> ---
>>  ip/iplink.c           |  2 +-
>>  man/man8/ip-link.8.in | 85 ++++++++++++++++++++++++++++++++++++++++=
+++++++++++
>>  2 files changed, 86 insertions(+), 1 deletion(-)
>>
>> diff --git a/ip/iplink.c b/ip/iplink.c
>> index dc98019..f677329 100644
>> --- a/ip/iplink.c
>> +++ b/ip/iplink.c
>> @@ -83,7 +83,7 @@ void iplink_usage(void)
>> =20
>>  	if (iplink_have_newlink()) {
>>  		fprintf(stderr, "\n");
>> -		fprintf(stderr, "TYPE :=3D { vlan | veth | vcan | dummy | ifb | m=
acvlan | can |\n");
>> +		fprintf(stderr, "TYPE :=3D { vlan | vxlan | veth | vcan | dummy |=
 ifb | macvlan | can |\n");
>>  		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit |=
 vxlan }\n");
>=20
> There was already a vxlan entry there.  Now there's two.
>=20
>=20
> Bj=C3=B8rn
>=20

Thanks oversight on my side.

--=20
Thomas Richter, Dept 3250, IBM LTC Boeblingen, Data Center Networking
--
Vorsitzende des Aufsichtsrats: Martina Koederitz=20
Gesch=C3=A4ftsf=C3=BChrung: Dirk Wittkopp
Sitz der Gesellschaft: B=C3=B6blingen / Registergericht: Amtsgericht St=
uttgart, HRB 243294
