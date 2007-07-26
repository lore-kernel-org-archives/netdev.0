From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/4 -rev1] Initilize and populate age field
Date: Thu, 26 Jul 2007 08:37:28 +0200
Message-ID: <46A84128.1090207@cosmosbay.com>
References: <20070726104554.cc95eedd.varunc@linux.vnet.ibm.com> <46A8391C.2020605@cosmosbay.com> <46A83EB9.6070903@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, shemminger@linux-foundation.org,
	krkumar2@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:40288 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754282AbXGZGiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 02:38:20 -0400
In-Reply-To: <46A83EB9.6070903@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan a =E9crit :
> Eric Dumazet wrote:
>> Varun Chandramohan a =E9crit :
>>> The age field is filled with the current time at the time of creati=
on
>>> of the route. When the routes are dumped
>>> then the age value stored in the route structure is subtracted from
>>> the current time value and the difference is the age expressed in s=
ecs.
>>>
>>>      }
>>> +
>>> +    do_gettimeofday(&tv);
>>> +    if (!*age) {
>>> +        *age =3D timeval_to_sec(&tv);
>>> +        NLA_PUT_U32(skb, RTA_AGE, *age);
>> here, what happens if sizeof(time_t) is not 4 ?
>>
> Same case as above :-) comments?

So you are confident it (truncation from 8 to 4 bytes) works well on Bi=
g=20
endian arches as well as Little endian arches ? :-)


