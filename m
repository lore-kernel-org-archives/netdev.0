From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Linux Route Cache performance tests
Date: Sun, 06 Nov 2011 22:57:39 +0100
Message-ID: <4EB702D3.1090703@itcare.pl>
References: <4EB6AE62.5050803@itcare.pl>    <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>   <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>  <1320608290.6506.33.camel@edumazet-laptop> <4EB6ED2E.1070106@itcare.pl> <1320614788.6506.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:38474 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939Ab1KFV5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Nov 2011 16:57:40 -0500
In-Reply-To: <1320614788.6506.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2011-11-06 22:26, Eric Dumazet pisze:
> Le dimanche 06 novembre 2011 =C3=A0 21:25 +0100, Pawe=C5=82 Staszewsk=
i a =C3=A9crit :
>> Yes with this is a little problem i think with kernel 3.1 because
>> dmesg | egrep  '(rhash)|(route)'
>> [    0.000000] Command line: root=3D/dev/md2 rhash_entries=3D2097152
>> [    0.000000] Kernel command line: root=3D/dev/md2 rhash_entries=3D=
2097152
>> [    4.697294] IP route cache hash table entries: 524288 (order: 10,
>> 4194304 bytes)
>>
>>
> Dont tell me you _still_ use a 32bit kernel ?
no it is 64bit :)
Linux localhost 3.1.0 #16 SMP Sun Nov 6 18:09:48 CET 2011 x86_64 Intel(=
R)
:)

> If so, you need to tweak alloc_large_system_hash() to use vmalloc,
> because you hit MAX_ORDER (10) page allocations.
funny then :)
Maybee i turned off too many kernel features
> But considering LOWMEM is about 700 Mbytes, you wont be able to creat=
e a
> lot of route cache entries.
>
> Come on, do us a favor, and enter new era of computing.
>
>
>
>
>
