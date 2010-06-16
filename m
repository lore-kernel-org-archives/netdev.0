From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 16216] New: wrong source addr of UDP packets
 when using policy routing
Date: Wed, 16 Jun 2010 19:43:16 +0200
Message-ID: <4C190D34.8080100@trash.net>
References: <bug-16216-10286@https.bugzilla.kernel.org/>	 <20100616093328.0671254b.akpm@linux-foundation.org>	 <4C18FFDC.8060102@trash.net> <1276709309.2632.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, borg@uu3.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44718 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759293Ab0FPRnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 13:43:18 -0400
In-Reply-To: <1276709309.2632.126.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mercredi 16 juin 2010 =C3=A0 18:46 +0200, Patrick McHardy a =C3=A9=
crit :
>
>  =20
>> This is know behaviour, fwmarks don't work for source address select=
ion
>> since before the source address is chosen, you don't even have a pac=
ket
>> which could be marked.
>>    =20
>
> We know have sk->sk_mark routing (socket based), so we might change
> sk->sk_mark with appropriate iptables target when one packet is
> received... not very clean but worth to mention...
>  =20
That would still be too late. The proper way would be to have the=20
application
set the socket mark.
