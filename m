From: Fan Du <fan.du@windriver.com>
Subject: Re: [RFC PATCH net-next V2] net: split rt_genid for ipv4 and ipv6
Date: Wed, 24 Jul 2013 16:12:55 +0800
Message-ID: <51EF8C87.4060707@windriver.com>
References: <1374543420-12657-1-git-send-email-fan.du@windriver.com> <20130723020437.GC30719@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <nicolas.dichtel@6wind.com>,
	<yoshfuji@linux-ipv6.org>, <jmorris@namei.org>,
	<steffen.klassert@secunet.com>, <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42794 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab3GXILw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 04:11:52 -0400
In-Reply-To: <20130723020437.GC30719@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hallo Hannes

On 2013=E5=B9=B407=E6=9C=8823=E6=97=A5 10:04, Hannes Frederic Sowa wrot=
e:
> On Tue, Jul 23, 2013 at 09:37:00AM +0800, Fan Du wrote:
>> Current net name space has only one genid for both IPv4 and IPv6, it=
 has below drawbacks:
>>
>> - Add/delete an IPv4 address will invalidate all IPv6 routing table =
entries.
>> - Insert/remove XFRM policy will also invalidate both IPv4/IPv6 rout=
ing table entries
>>    even when the policy is only applied for one address family.
>>
>> Thus, this patch attempt to split one genid for two to cater for IPv=
4 and IPv6 separately
>> in a fine granularity.
>
> For me the approach seems reasonable. We should double-check if this
> does not affect v4mapped af_inet6 sockets in any way. I could help to
> do the review if there is an agreement that the split is desirable.

Thank you for your attention :)

v4mapped af_inet6 address shouldn't cause problem, as long as the mappe=
d
v4 address is routable in IPv4 stack, so add/delete IPv6 address doesn'=
t
interfere IPv4 routing entry.

> Thanks,
>
>    Hannes
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
