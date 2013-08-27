From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier
 for xfrm tunnel mode callback
Date: Tue, 27 Aug 2013 09:40:37 +0800
Message-ID: <521C0395.8040607@windriver.com>
References: <1377240424-11758-1-git-send-email-fan.du@windriver.com> <20130826113559.GM26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <saurabh.mohan@vyatta.com>, <herbert@gondor.hengli.com.au>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60377 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab3H0BkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 21:40:20 -0400
In-Reply-To: <20130826113559.GM26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Steffen

Thanks for your attention :)

On 2013=E5=B9=B408=E6=9C=8826=E6=97=A5 19:35, Steffen Klassert wrote:
> On Fri, Aug 23, 2013 at 02:47:04PM +0800, Fan Du wrote:
>> Some thoughts on IPv4 VTI implementation:
>>
>> The connection between VTI receiving part and xfrm tunnel mode input=
 process
>> is hardly a "xfrm_tunnel", xfrm_tunnel is used in places where, e.g =
ipip/sit
>> and xfrm4_tunnel, acts like a true "tunnel" device.
>>
>> In addition, IMHO, VTI doesn't need vti_err to do something meaningf=
ul, as all
>> VTI needs is just a notifier to be called whenever xfrm_input ingres=
s a packet
>> to update statistics.
>>
>> So this patch introduce xfrm_tunnel_notifier and meanwhile wipe out =
vti_erri
>> code.
>
> Btw. who calls vti_err()? I don't see a hook which would call the vti
> error handler. I'm still not absolutely sure whether we need it or no=
t,
> but we should either remove it or add a hook to call it.

Yes, nobody calls vti_err. Maybe the vti_err comes from ipip_err as com=
ments in
the file header said ip_vti.c cloned from ipip.c.

I have describe my statement in the reply for Dave's question. Please r=
eview.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
