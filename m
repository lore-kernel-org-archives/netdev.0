From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network namespace and tc?
Date: Thu, 14 Feb 2008 09:37:25 +0100
Message-ID: <47B3FDC5.4050409@fr.ibm.com>
References: <20080213155903.4ab6e454@extreme> <1202976470.7894.8.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:40531 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895AbYBNIpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 03:45:10 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m1E8j7Pt168202
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2008 08:45:07 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1E8j6A51470626
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2008 08:45:06 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1E8inRv009484
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2008 08:44:50 GMT
In-Reply-To: <1202976470.7894.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> Hello, Stephen!
>=20
> Namespaces are not fully implemented yet :) Right now we we have only
> basic infrastructure in the mainstream and, currently, we can't even =
run
> TCP in different namespace :( We hope this will be changed very soon.
>=20
> These marks (net !=3D &init_net) are used to
> - mark places we need to modify
> - ensure that we do not break initial namespace.
>=20
> Regards,
> 	Den
>=20
> On Wed, 2008-02-13 at 15:59 -0800, Stephen Hemminger wrote:
>> It looks like tc filter won't work on alternate namespaces:
>> /* Add/change/delete/get a filter node */
>>
>> static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, v=
oid *arg)
>> {
>> ...
>>
>> 	if (net !=3D &init_net)
>> 		return -EINVAL;
>>
>>
>> Haven't played with namespace virtualization yet, but what else is
>> not supported?  Where is this documented?

I wrote some documentation here:

http://lxc.sourceforge.net/network.php

That talk about configuration, bench, etc ...

Your question make me feel I should add a matrix with the current state=
=20
of the network namespace, what is in, what is done but not merged yet,=20
what is planned and what is not planned.

Thanks for paying attention at this.

   -- Daniel


















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92=
400
Courbevoie
RCS Nanterre 552 118 465
=46orme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
