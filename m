From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 15:58:51 +0100
Message-ID: <20110218145850.GF2939@psychotron.redhat.com>
References: <20110218132524.GC2939@psychotron.redhat.com>
 <1298035791.6201.56.camel@edumazet-laptop>
 <20110218141456.GD2939@psychotron.redhat.com>
 <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	fubar@us.ibm.com, nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755486Ab1BRPAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 10:00:34 -0500
Content-Disposition: inline
In-Reply-To: <4D5E8655.5070304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Feb 18, 2011 at 03:46:45PM CET, kaber@trash.net wrote:
>Am 18.02.2011 15:27, schrieb Eric Dumazet:
>> Le vendredi 18 f=E9vrier 2011 =E0 15:14 +0100, Jiri Pirko a =E9crit =
:
>>=20
>>> Do not know how to do it better. As for percpu variable, not only
>>> origdev would have to be remembered but also probably skb pointer t=
o
>>> know if it's the first run on the skb or not. Can't really figure o=
ut a
>>> better solution. Can you?
>>=20
>> I'll try and let you know.
>
>Why not simply do a lookup on skb->iif?

Well I was trying to avoid iterating over list of devices for each
incoming frame.

