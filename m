From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Fri, 10 Jan 2014 17:23:40 +0800
Message-ID: <52CFBC1C.7010809@windriver.com>
References: <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com> <52B26553.9070103@windriver.com> <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com> <52B3BAD1.30205@windriver.com> <20131224103521.GB29716@secunet.com> <52BA7DE4.9070404@windriver.com> <20131225101104.224f9b87@vostro> <52BA9AEA.7050301@windriver.com> <20140106103512.GR31491@secunet.com> <52CB69DA.7000101@windriver.com> <20140109123803.GZ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Timo Teras <timo.teras@iki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:46949 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbaAJJYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:24:21 -0500
In-Reply-To: <20140109123803.GZ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2014=E5=B9=B401=E6=9C=8809=E6=97=A5 20:38, Steffen Klassert wrote:
> On Tue, Jan 07, 2014 at 10:43:38AM +0800, Fan Du wrote:
>> >
>> >  Yes, I tested sk policy with udp, when transmit, dst will be cach=
ed into sk
>> >  by sk_dst_set. Let's leave current implementation as it is.
>> >
>> >  Please kindly review if there is any concern about v4.
> Why do you want to keep the current implementation? We don't
> use the cached bundles. I'd remove this caching with the patch
> below during the next development cycle if nobody has a good
> reason why we should keep it.
>
>
> Subject: [PATCH RFC] xfrm: Remove caching of xfrm_policy_sk_bundles
>
> We currently cache socket policy bundles at xfrm_policy_sk_bundles.
> These cached bundles are never used. Instead we create and cache
> a new one whenever xfrm_lookup() is called on a socket policy.
>
> Most protocols cache the used routes to the socket, so let's
> remove the unused caching of socket policy bundles in xfrm.

Honestly speaking, I cannot think of any other obvious reason
to retain sk bundle cache for what I know about XFRM so far, though
this mysterious ancient code still puzzles me.

Acked-by: Fan Du <fan.du@windriver.com>

> Signed-off-by: Steffen Klassert<steffen.klassert@secunet.com>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
