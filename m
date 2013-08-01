From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next v4] net: split rt_genid for ipv4 and ipv6
Date: Thu, 1 Aug 2013 08:33:57 +0800
Message-ID: <51F9ACF5.6080807@windriver.com>
References: <1375144433-731-1-git-send-email-fan.du@windriver.com>	<20130730070702.GG2490@order.stressinduktion.org> <20130731.145710.1507535169314670977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <hannes@stressinduktion.org>, <nicolas.dichtel@6wind.com>,
	<yoshfuji@linux-ipv6.org>, <jmorris@namei.org>,
	<steffen.klassert@secunet.com>, <paul@paul-moore.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47088 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab3HAAcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:32:20 -0400
In-Reply-To: <20130731.145710.1507535169314670977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8801=E6=97=A5 05:57, David Miller wrote:
> From: Hannes Frederic Sowa<hannes@stressinduktion.org>
> Date: Tue, 30 Jul 2013 09:07:02 +0200
>
>> On Tue, Jul 30, 2013 at 08:33:53AM +0800, Fan Du wrote:
>>> Current net name space has only one genid for both IPv4 and IPv6, i=
t has below
>>> drawbacks:
>>>
>>> - Add/delete an IPv4 address will invalidate all IPv6 routing table=
 entries.
>>> - Insert/remove XFRM policy will also invalidate both IPv4/IPv6 rou=
ting table
>>>    entries even when the policy is only applied for one address fam=
ily.
>>>
>>> Thus, this patch attempt to split one genid for two to cater for IP=
v4 and IPv6
>>> separately in a fine granularity.
>>>
>>> Signed-off-by: Fan Du<fan.du@windriver.com>
>>
>> Also this patch only applies with some fuzz, it addressed all my iss=
ues:
>>
>> Acked-by: Hannes Frederic Sowa<hannes@stressinduktion.org>
>
> Applied, thanks.
>

Thanks Dave, Hannes, Steffen and Nicolas for reviewing this patch!

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
