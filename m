From: =?UTF-8?B?T3J0d2luIEdsw7xjaw==?= <odi@odi.ch>
Subject: Re: 3.14 regression: huge latency in read/select on tun
Date: Mon, 21 Apr 2014 10:40:55 +0200
Message-ID: <5354D997.70604@odi.ch>
References: <533C381E.9090103@odi.ch>		 <1396456973.3989.41.camel@edumazet-glaptop2.roam.corp.google.com>		 <533D133A.3090008@odi.ch>		 <1396531176.12330.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <1396533026.12330.9.camel@edumazet-glaptop2.roam.corp.google.com>	 <5352D8FF.6070305@odi.ch> <1398011495.19600.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gerben@daybyday.nl, Vlad Yasevich <vyasevic@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fep17.mx.upcmail.net ([62.179.121.37]:36986 "EHLO
	fep17.mx.upcmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbaDUIlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 04:41:03 -0400
In-Reply-To: <1398011495.19600.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20.04.2014 18:31, Eric Dumazet wrote:> On Sat, 2014-04-19 at 22:13
+0200, Ortwin Gl=C3=BCck wrote:
>> On 03.04.2014 15:50, Eric Dumazet wrote:
>>
>> I finally found time to bisect this:
>>
>> commit 53d6471cef17262d3ad1c7ce8982a234244f68ec
>> Author: Vlad Yasevich <vyasevic@redhat.com>
>> Date:   Thu Mar 27 17:26:18 2014 -0400
>>
>>     net: Account for all vlan headers in skb_mac_gso_segment
>
> Hmm.. probably already solved by commit
> 1e785f48d29a09b6cf96db7b49b6320dada332e1
> ("net: Start with correct mac_len in skb_network_protocol")

Indeed that fixes it. I have cherry picked that onto 3.14 and it works.
That means 1e785f48 should be applied to stable 3.13.y and 3.14.y too.

Thanks,

Ortwin
