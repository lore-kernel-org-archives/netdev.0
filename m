From: Simeon Penev <spenev@istac.de>
Subject: Re: Patch for MTU in the routing table cache
Date: Fri, 02 Mar 2012 14:49:21 +0100
Message-ID: <4F50CFE1.5040605@istac.de>
References: <4F50C789.8050709@istac.de> <1330695791.2469.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from warnix.istac.de ([212.18.16.42]:58639 "EHLO warnix.istac.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754945Ab2CBNtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 08:49:23 -0500
In-Reply-To: <1330695791.2469.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

no, i didn't. I'm new to the developer list and just wanted to post a=20
patch proposition. I hoped that the maintainer of the code (probably=20
Alan Cox) will decide whether to use it.

Best regards,
Simeon

On 03/02/2012 02:43 PM, Eric Dumazet wrote:
> Le vendredi 02 mars 2012 =C3=A0 14:13 +0100, Simeon Penev a =C3=A9cri=
t :
>> Hi,
>>
>> after testing the new 3.2 kernel and the new route caching code, i'v=
e
>> found a bug in net/ipv4/route.c. The route cache does not detect cha=
nges
>> to the MTU of the interface. Therefore IP fragmentation will happen =
with
>> false MTU. Please see attached the proposed patch.
>>
> Hi
>
> Did you test this patch doesnt break things like
>
> ip ro add 96.17.148.89 via 10.0.0.1 mtu 800
>
> (and keep eth0 mtu being standard mtu)
>
>
>
>
