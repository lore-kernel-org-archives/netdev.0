From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 12:52:42 +0200
Message-ID: <4A44A87A.4010601@gmail.com>
References: <4A439C6B.9090502@itcare.pl> <4A43E9F1.90209@cosmosbay.com> <4A43F1A2.3090108@itcare.pl> <4A440019.3020009@gmail.com> <4A449DAD.9030606@itcare.pl> <4A44A41A.6080608@gmail.com> <4A44A728.1000202@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57924 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbZFZKwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 06:52:51 -0400
In-Reply-To: <4A44A728.1000202@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=B3 Staszewski a =E9crit :
> Eric Dumazet pisze:
    =20
>>
>> Yes, I was a fool to ask you to try 2.6.31-rc1, sorry.
>>
>>  =20
> No problem with this test i lost only one test failover and no traffi=
c
> lost when system switch to primary routers. :)
>> Even 2.6.30 is too young for a production machine.
>>  =20
> I alvays make like this - i have iBGP mesh with main access path of
> machines on stable 2.6.28.9 kernels and second failover path  on
> machines  that use  newest kernel for  testing in this case  2.6.29 b=
ut
> after some problems i try also 2.6.30  yestarday.
>> 2.6.29.5 contains the fixes, Pawel, did you tried this version ?
>>
>>
>>  =20
> I will try 2.6.29.5 today
>=20
OK thanks

Please report (while machine has enough load) output of

rtstat -c20 -i1

(rtstat is a symbolic link to lnstat, if not provided by your distro)

