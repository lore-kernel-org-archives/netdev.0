From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] netfilter: add IPComp extension match support
Date: Fri, 6 Dec 2013 17:56:09 +0800
Message-ID: <52A19F39.3030702@windriver.com>
References: <1385607204-27650-1-git-send-email-fan.du@windriver.com> <20131205183402.GA8949@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131205183402.GA8949@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2013=E5=B9=B412=E6=9C=8806=E6=97=A5 02:34, Pablo Neira Ayuso wrote:
> Hi,
>
> On Thu, Nov 28, 2013 at 10:53:24AM +0800, Fan Du wrote:
>> With this plugin, user could specify IPComp tagged with certain
>> CPI that host not interested will be DROPped or any other action.
>>
>> For example:
>> iptables -A INPUT -p 108 -m ipcomp --ipcompspi 0x87 -j DROP
>>
>> Then input IPComp packet with CPI equates 0x87 will not reach
>> upper layer anymore.
>
> I think that, with a little bit more work, you can add support for
> IPv6 as well. From RFC 3173:
>
> "In the IPv6 context, IPComp is viewed as an end-to-end payload, and
> MUST NOT apply to hop-by-hop, routing, and fragmentation extension
> headers.
>
> You can perform that IPv6-specific handling to skip these extension
> headers and reach the IPComp header by means of the ipv6_find_hdr()
> helper function.
>
> BTW, please post the iptables userspace part as well.

Thanks for your attention, Pablo.
I will try to finish your request this weekend, hopefully post the whol=
e
patch set in early next week.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan fan
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
