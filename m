From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4 -rev1] Initilize and populate age field
Date: Thu, 26 Jul 2007 12:29:22 +0530
Message-ID: <46A8464A.1020400@linux.vnet.ibm.com>
References: <20070726104554.cc95eedd.varunc@linux.vnet.ibm.com> <46A8391C.2020605@cosmosbay.com> <46A83EB9.6070903@linux.vnet.ibm.com> <46A84128.1090207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, shemminger@linux-foundation.org,
	krkumar2@in.ibm.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:37354 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765670AbXGZG7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 02:59:06 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6Q6x6u3012185
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 02:59:06 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6Q6x64N208052
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 00:59:06 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6Q6x5LB026761
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 00:59:06 -0600
In-Reply-To: <46A84128.1090207@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Varun Chandramohan a =E9crit :
>> Eric Dumazet wrote:
>>> Varun Chandramohan a =E9crit :
>>>> The age field is filled with the current time at the time of creat=
ion
>>>> of the route. When the routes are dumped
>>>> then the age value stored in the route structure is subtracted fro=
m
>>>> the current time value and the difference is the age expressed in
>>>> secs.
>>>>
>>>>      }
>>>> +
>>>> +    do_gettimeofday(&tv);
>>>> +    if (!*age) {
>>>> +        *age =3D timeval_to_sec(&tv);
>>>> +        NLA_PUT_U32(skb, RTA_AGE, *age);
>>> here, what happens if sizeof(time_t) is not 4 ?
>>>
>> Same case as above :-) comments?
>
> So you are confident it (truncation from 8 to 4 bytes) works well on
> Big endian arches as well as Little endian arches ? :-)
>
I suppose so. But i must admit i have'nt tested it on Big endian arch
though!!!
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

