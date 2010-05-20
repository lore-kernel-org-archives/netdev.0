From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: RFC: netfilter: synproxy iptables target
Date: Thu, 20 May 2010 22:42:25 +0800
Message-ID: <AANLkTimLBc58O4FA2S5wsA0kDD6eP7je_OGapfhPQK1s@mail.gmail.com>
References: <AANLkTimp6S7MpwDAT8l-M0ZWjs2HIcUEfL5f8j9-QDZh@mail.gmail.com>
	<4BF54310.6030004@trash.net> <AANLkTimjY_0yKfMtAUxI7He-QH5R5AdDCR3V8eKSgbGq@mail.gmail.com>
	<1274365963.4046.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1274365963.4046.39.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 20, 2010 at 10:32 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 20 mai 2010 =C3=A0 22:21 +0800, Changli Gao a =C3=A9crit :
>
>>
>> pure synproxy can be used on firewall to protect the internal server=
s,
>> which don't support neither syncookies and synproxy, from the attack
>> of SYN-flood.
>>
>
> protecting servers using conntracking ?
>
> Thats seems very dangerous to me.

If NAT is needed, conntracking is needed in any way. The conntrack
won't be confirmed until the connection between firewall and client is
established.

>
>> synproxy with defered connection relay acts as a layer 7 proxy, but
>> works in kernel space totally, unlike tcp splice tech., which needs
>> the applications in user space parse the requests, and establish the
>> connections.
>>
>
> In the example given, only non persistent connections are handled...
>
> These days, browsers and servers dont establish one socket per http
> request...
>
>

Yea. But some users still use non persistent connections, as they want
to fetch URLs in parallel.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
