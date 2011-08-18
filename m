From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: Linux vs FreeBSD Which is correct.
Date: Thu, 18 Aug 2011 08:42:32 -0400
Message-ID: <4E4D08B8.8020309@earthlink.net>
References: <4E4BF456.9000807@earthlink.net> <201108172017.48683.remi@remlab.net> <4E4C1A00.80207@earthlink.net> <4E4C2178.1000809@plouf.fr.eu.org>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-15?Q?R=E9mi_Denis-Courmont?= <remi@remlab.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pascal Hambourg <pascal@plouf.fr.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:49569 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755765Ab1HRMmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 08:42:37 -0400
In-Reply-To: <4E4C2178.1000809@plouf.fr.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2011 04:15 PM, Pascal Hambourg wrote:
> Hello,
>
> Stephen Clark a =E9crit :
>   =20
>> On 08/17/2011 01:17 PM, R=E9mi Denis-Courmont wrote:
>>     =20
>>> Le mercredi 17 ao=FBt 2011 20:03:18 Stephen Clark, vous avez =E9cri=
t :
>>>
>>>       =20
>>>> I have run into a situation where if I ping our HQ the response co=
mes
>>>> back on a different
>>>> interface than what the request went out on. FreeBSD is happy and =
says
>>>> it got the response,
>>>> Linux is not and gives no indication it got a response.
>>>>
>>>> So is FreeBSD wrong or is Linux wrong?
>>>>         =20
> Neither is right or wrong. It partly depends whether you want to enfo=
rce
> so-called "weak" or "strong" host model.
>
>   =20
>>> Most distributions enable reverse path filtering by default.
>>> It can be disabled:
>>> # echo -n 0>   /proc/sys/net/ipv4/conf/all/rp_filter
>>>
>>> But you should probably fix the configuration instead (e.g. /etc/sy=
sctl.conf).
>>>
>>>       =20
>> Sorry that didn't help either.
>>     =20
> Since some kernel version the logic of this sysctl has changed from
> AND(all, $interface) to MAX(all, $interface). So you must set
> net/ipv4/conf/$interface/rp_filter to 0 too to disable it.
> Or set net/ipv4/conf/all/rp_filter to 2 to make it weaker.
>
>   =20
I guess I don't really understand what reverse path filter stuff is all=
=20
about, much less making it weaker.
But using 2 made the pings responses be seen.

--=20

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



