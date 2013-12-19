From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 0/2] netfilter: IPv4/v6 IPcomp match support
Date: Thu, 19 Dec 2013 11:30:09 +0800
Message-ID: <52B26841.40800@windriver.com>
References: <1386937082-30412-1-git-send-email-fan.du@windriver.com> <20131217130555.GA8874@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <steffen.klassert@secunet.com>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131217130555.GA8874@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2013=E5=B9=B412=E6=9C=8817=E6=97=A5 21:05, Pablo Neira Ayuso wrote:
> On Fri, Dec 13, 2013 at 08:18:00PM +0800, Fan Du wrote:
>> Hi,
>>
>> This patchset adds IPv4/v6 IPComp 'match' plugin to enables user set=
ting
>> ACTONs for IPcomp flows sepecified with SPI value.
>>
>> Corresponding iptables patchset will be sent here after soon.
>>
>> Fan Du (2):
>>    netfilter: add IPv4 IPComp extension match support
>>    netfilter: add IPv6 IPComp extension match support
>
> This looks good, but I have to ask you to merge those two modules int=
o
> one single xt_ipcomp, they are fairly small and we can save the
> overhead of having two different modules. Moreover, at quick glance I
> don't see any dependency with IPv4/IPv6 exported symbols that may
> cause ifdef pollution.
>
> Please, see net/netfilter/xt_tcpudp.c as reference to rework this.
> Thanks.
>

I noticed netfilter ipv4/v6 AH support also has split implementation,
so far, by my understanding, it's fairly enough to consolidate those
two implementations into one as well, as IPv4/6 AH head format are
identical.

If you don't mind or it won't break anything internal for netfilter,
I plan to combine them into one piece.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
