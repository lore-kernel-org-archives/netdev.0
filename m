From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH] Age Entry For IPv4 Route Table
Date: Mon, 25 Jun 2007 13:28:37 +0530
Message-ID: <467F75AD.1090004@linux.vnet.ibm.com>
References: <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com> <20070625.141451.21870598.yoshfuji@linux-ipv6.org> <467F50E3.2050405@linux.vnet.ibm.com> <20070625.003208.69400937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, sri@us.ibm.com,
	dlstevens@us.ibm.com, varuncha@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:35396 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbXFYH64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 03:58:56 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5P7wuvs024429
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 03:58:56 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5P7wurE488280
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 03:58:56 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5P7wtee028858
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 03:58:55 -0400
In-Reply-To: <20070625.003208.69400937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
> Date: Mon, 25 Jun 2007 10:51:39 +0530
>
>  =20
>> YOSHIFUJI Hideaki / =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=
=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD wrote:
>>    =20
>>> In article <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com> (at =
Mon, 25 Jun 2007 10:28:38 +0530), Varun Chandramohan <varunc@linux.vnet=
=2Eibm.com> says:
>>>
>>>  =20
>>>      =20
>>>> According to the RFC 4292 (IP Forwarding Table MIB) there is a nee=
d for an age entry for all the routes in the routing table. The entry i=
n the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
>>>> Many snmp application require this age entry. So iam adding the ag=
e field in the routing table and providing
>>>> the interface for this value via /proc/net/route.
>>>>    =20
>>>>        =20
>>> I'm not in favor of adding new field(s) to /proc/net/route.
>>>
>>>  =20
>>>      =20
>> Do you think it will break any user level functionality? I have test=
ed
>> with netstat, route and net-snmp which reads from the same /proc
>> interface. They seem to work fine.
>>    =20
>
> You can't change procfs file output format, someone's shell scripts
> or whatever out there will break.  Just testing some common packages
> isn't a way to be able to change procfs file output, it's a user
> exported API and just like system calls you cannot change them.
>
>  =20
Hi Dave,
   =20
        Ok i understand. But can you suggest anyother way to do the abo=
ve?

Regards,
Varun
