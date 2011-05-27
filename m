From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.11
Date: Fri, 27 May 2011 09:40:40 +0200
Message-ID: <BANLkTimJMQ8Gc4Jj3eZC50hLp-=zXQgekg@mail.gmail.com>
References: <4DDE857E.40807@trash.net>
	<1306434537.2543.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, NetDev <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:51747 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab1E0Hkn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 03:40:43 -0400
In-Reply-To: <1306434537.2543.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

you could try with -M '' (or something like that) if you want to
prevent even xtables from being loaded.
Although that will probably still not prevent iptable_filter from
being loaded if ip_tables is already loaded...

On Thu, May 26, 2011 at 20:28, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Le jeudi 26 mai 2011 =C3=A0 18:53 +0200, Patrick McHardy a =C3=A9crit=
 :
>> The netfilter coreteam presents:
>>
>> =C2=A0 =C2=A0 iptables version 1.4.10
>>
>> the iptables release for the 2.6.39 kernels. Due to some mistakes
>> on my side we didn't have a release for longer than expected, so
>> this contains a rather large number of changes.
>>
>> Changes include:
>>
>
> ...
>> - a new iptables option "-C" to check for existance of a rules
>
> Nice, but this still loads modules...
>
> # lsmod | grep ipta
> # ./iptables -C INPUT -p tcp
> iptables: Bad rule (does a matching rule exist in that chain?).
> # lsmod | grep ipta
> iptable_filter =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01730 =C2=A00
> ip_tables =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A015958 =C2=A0=
1 iptable_filter
> x_tables =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 22998 =C2=A0=
3 iptable_filter,ip_tables,xt_tcpudp
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
