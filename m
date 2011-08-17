From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: Linux vs FreeBSD Which is correct.
Date: Wed, 17 Aug 2011 15:44:00 -0400
Message-ID: <4E4C1A00.80207@earthlink.net>
References: <4E4BF456.9000807@earthlink.net> <201108172017.48683.remi@remlab.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:60935 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751200Ab1HQToD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 15:44:03 -0400
In-Reply-To: <201108172017.48683.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2011 01:17 PM, R=E9mi Denis-Courmont wrote:
> Le mercredi 17 ao=FBt 2011 20:03:18 Stephen Clark, vous avez =E9crit =
:
>   =20
>> I have run into a situation where if I ping our HQ the response come=
s
>> back on a different
>> interface than what the request went out on. FreeBSD is happy and sa=
ys
>> it got the response,
>> Linux is not and gives no indication it got a response.
>>
>> So is FreeBSD wrong or is Linux wrong?
>>     =20
> Most distributions enable reverse path filtering by default.
> It can be disabled:
> # echo -n 0>  /proc/sys/net/ipv4/conf/all/rp_filter
>
> But you should probably fix the configuration instead (e.g. /etc/sysc=
tl.conf).
>
>   =20
Sorry that didn't help either.

--=20

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



