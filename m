From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Tue, 17 Mar 2009 08:08:23 +0100
Message-ID: <49BF4C67.9000808@cosmosbay.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>	 <49BC69D5.5000002@cosmosbay.com> <91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com> <49BEA1ED.4010907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dave Boutcher <daveboutcher@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53213 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbZCQHI2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 03:08:28 -0400
In-Reply-To: <49BEA1ED.4010907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Dave Boutcher a =E9crit :
>> On Sat, Mar 14, 2009 at 9:37 PM, Eric Dumazet <dada1@cosmosbay.com> =
wrote:
>>> Dave Boutcher a =E9crit :
>>>> I'm running into an interesting problem with joining multiple
>>>> multicast feeds.  If you join multiple multicast feeds using
>>>> setsockopt(...,IP_ADD_MEMBERSHIP...) it causes packets on UNRELATE=
D
>>>> multicast feeds to get dropped.  We have a multicast feed on a roc=
k
>>>> solid network, and we were very surprised to see dropped packets. =
 The
>>>> cause was a different process/program being run by a different use=
r
>>>> joining a bunch of mulitcast feeds.
>>> I could not reproduce the problem on my machines (bnx2 adapter), ev=
en if changing
>>> NUMSOCK from 55 to 200 in joiner.c
>> Thanks for trying Eric.  Based on your email I did some more testing
>> and thus far I've
>> only recreated this on x86_64 arches, not on i386.  Which arch did y=
ou
>> try it on?
>=20
> I tried both, 32 and 64 bit kernels. No problems so far.
>=20
> Could you post a linux kernel .config of a non 'working' machine, and=
 dmesg output ?
>=20

Also, is using a third machine to start your joiner program is able to =
trigger
packet losses too ?


