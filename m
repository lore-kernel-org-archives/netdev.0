From: Karel Rericha <karel@maxtel.cz>
Subject: Re: Quick Fair Queue scheduler maturity and examples
Date: Thu, 27 Oct 2011 14:46:07 +0200
Message-ID: <CAN==1Rq+WEcezLPNPNug2V11nftDkm2=aRKw95u_R8OPGxG72g@mail.gmail.com>
References: <CAN==1RowdZ094pkOA3vbs-fd3g-NSABqaGC3WXSPL8Y0Lqg+fQ@mail.gmail.com>
	<1319716772.2601.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63214 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790Ab1J0MqI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 08:46:08 -0400
Received: by vws1 with SMTP id 1so2357593vws.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 05:46:07 -0700 (PDT)
In-Reply-To: <1319716772.2601.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/27 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 27 octobre 2011 =E0 13:30 +0200, Karel Rericha a =E9crit :
>> Hi list,
>>
>> has anyone some experience about QFQ and its maturity ? I was not ab=
le
>> to find anything more than patches and papers, real world examples a=
nd
>> info are nonexistent.
>>
>
> At its inclusion time (in linux 3.0), I did many tests and feedback t=
o
> Stephen.
>
> By the way, QFQ is not only patches and papers, its now officially
> supported by linux netdev team ;)
>
> Unfortunately the machine where I kept traces of my qfq scripts was
> totally lost, no backups.... oh well...
>
> Given that not a single patch was added since initial commit, I guess
> nobody really uses the thing, or its perfect, who knows :)
>
> You definitely should be able to use it, and report here problems if
> any.
>

Actually I am doing some reseach to replace our main shaping machine
with 60 000+ htb classes, which now saturates 12 core Xeon Westmere to
30% (there are five gigabit network ports on each interface affinited
to cores). AFAIK QFQ should be O(1) complexity so it would bring
saturation a requirements for number of cores down considerably (HTB
has O(log(N)) complexity).

I have test machine and about two months to decide if we will stay
with HTB or we will try something else. So it would be VERY helpful,
if you would search you memory instead your dead disk :-) and send me
some example of QFQ usage, if I can ask for a little of your time. I
promise to have results published here in return.

Thanks, Karel

BTW I can provide some virtual Gentoo servers for test setup if you
would want participate in further testing.
