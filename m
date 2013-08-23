From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH RFC 2/2] ipv6: Add support for IPsec virtual tunnel interfaces
Date: Fri, 23 Aug 2013 14:17:14 +0800
Message-ID: <5216FE6A.3000009@windriver.com>
References: <20130819062623.GN26773@secunet.com> <20130819062730.GP26773@secunet.com> <5215C1F4.9030609@windriver.com> <20130823061214.GG26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38837 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab3HWGQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 02:16:59 -0400
In-Reply-To: <20130823061214.GG26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8823=E6=97=A5 14:12, Steffen Klassert wrote:
> On Thu, Aug 22, 2013 at 03:47:00PM +0800, Fan Du wrote:
>> >
>> >
>> >  On 2013=E5=B9=B408=E6=9C=8819=E6=97=A5 14:27, Steffen Klassert wr=
ote:
>>> >  >+
>>> >  >+	skb_dst_drop(skb);
>>> >  >+	skb_dst_set_noref(skb, dst);
>>> >  >+
>>> >  >+	ip6tunnel_xmit(skb, dev);
>>> >  >+	if (ndst)
>>> >  >+		ip6_tnl_dst_store(t, ndst);
>>> >  >+	return 0;
>>> >  >+tx_err_link_failure:
>>> >  >+	stats->tx_carrier_errors++;
>>> >  >+	dst_link_failure(skb);
>>> >  >+tx_err_dst_release:
>> >
>> >  Maybe it's necessary to count stats->tx_errors as well.
> We count it directly after an error return of this function.
>
>

My bad, you are right ;)


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
