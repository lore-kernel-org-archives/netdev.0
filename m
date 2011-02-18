From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 16:50:23 +0100
Message-ID: <4D5E953F.6010606@trash.net>
References: <20110218132524.GC2939@psychotron.redhat.com> <1298035791.6201.56.camel@edumazet-laptop> <20110218141456.GD2939@psychotron.redhat.com> <1298039252.6201.66.camel@edumazet-laptop> <4D5E8655.5070304@trash.net> <20110218145850.GF2939@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	fubar@us.ibm.com, nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46033 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393Ab1BRPu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 10:50:26 -0500
In-Reply-To: <20110218145850.GF2939@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.02.2011 15:58, Jiri Pirko wrote:
> Fri, Feb 18, 2011 at 03:46:45PM CET, kaber@trash.net wrote:
>> Am 18.02.2011 15:27, schrieb Eric Dumazet:
>>> Le vendredi 18 f=E9vrier 2011 =E0 15:14 +0100, Jiri Pirko a =E9crit=
 :
>>>
>>>> Do not know how to do it better. As for percpu variable, not only
>>>> origdev would have to be remembered but also probably skb pointer =
to
>>>> know if it's the first run on the skb or not. Can't really figure =
out a
>>>> better solution. Can you?
>>>
>>> I'll try and let you know.
>>
>> Why not simply do a lookup on skb->iif?
>=20
> Well I was trying to avoid iterating over list of devices for each
> incoming frame.
>=20

Well, there are a couple of holes on 64 bit, perhaps you can rearrange
things and eliminate either iif or input_dev without increasing size
since they appear to be redundant.
