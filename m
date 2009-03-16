From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Mon, 16 Mar 2009 20:01:01 +0100
Message-ID: <49BEA1ED.4010907@cosmosbay.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>	 <49BC69D5.5000002@cosmosbay.com> <91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dave Boutcher <daveboutcher@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54383 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758571AbZCPTBJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 15:01:09 -0400
In-Reply-To: <91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Boutcher a =E9crit :
> On Sat, Mar 14, 2009 at 9:37 PM, Eric Dumazet <dada1@cosmosbay.com> w=
rote:
>> Dave Boutcher a =E9crit :
>>> I'm running into an interesting problem with joining multiple
>>> multicast feeds.  If you join multiple multicast feeds using
>>> setsockopt(...,IP_ADD_MEMBERSHIP...) it causes packets on UNRELATED
>>> multicast feeds to get dropped.  We have a multicast feed on a rock
>>> solid network, and we were very surprised to see dropped packets.  =
The
>>> cause was a different process/program being run by a different user
>>> joining a bunch of mulitcast feeds.
>> I could not reproduce the problem on my machines (bnx2 adapter), eve=
n if changing
>> NUMSOCK from 55 to 200 in joiner.c
>=20
> Thanks for trying Eric.  Based on your email I did some more testing
> and thus far I've
> only recreated this on x86_64 arches, not on i386.  Which arch did yo=
u
> try it on?

I tried both, 32 and 64 bit kernels. No problems so far.

Could you post a linux kernel .config of a non 'working' machine, and d=
mesg output ?

>=20
>> Is your network a 100Mb one or Gigabit ?
>> Try to slow down your joiner ?
>> (Could be a flood of IGMP messages your router/switch cannot cope wi=
th)
>>
>> Please describe your "rock solid" network setup (kind of network ada=
pters you have, kind of router...)
>=20
> The problem originally manifest itself at work on a 24-core Dell
> server with 6 NICs.   The network
> is gigabit with a Cisco 4900 switch.  I recreated it in my basement o=
n
> my little white-box
> system and a cheap netgear switch.  The NIC at work is Intel e1000e
> driver, the one
> at home is also e1000.
>=20
>> If using tcpdump to force promiscuous mode on the device also trigge=
rs packet losses ?
>>
>> (see also ifconfig ethX promisc|allmulti)
>=20
> I haven't had a chance to play with promiscuous yet...
>=20


