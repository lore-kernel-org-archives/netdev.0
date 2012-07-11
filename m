From: Li Yu <raise.sail@gmail.com>
Subject: Re: [RFC][PATCH 1/4] skbtrace: core feature
Date: Wed, 11 Jul 2012 14:15:40 +0800
Message-ID: <4FFD1A0C.8090909@gmail.com>
References: <4FFBC6B6.2000600@gmail.com>  <4FFCE241.6010305@gmail.com> <1341979398.3265.6648.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56420 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887Ab2GKGPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:15:46 -0400
Received: by pbbrp8 with SMTP id rp8so1497352pbb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 23:15:46 -0700 (PDT)
In-Reply-To: <1341979398.3265.6648.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8811=E6=97=A5 12:03, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Wed, 2012-07-11 at 10:17 +0800, Li Yu wrote:
>> From: Li Yu <bingtian.ly@taobao.com>
>>
>> This implements core feature of skbtrace, which contains glue code o=
f
>> tracepoints subsystem and relay file system, and provide skbtrace AP=
I
>> for particular networking traces.
>>
>> Thanks
>
> Hi Li
>
> This seems a huge amount of code, on an already complex stack.
>
> I am not convinced its needed. It looks like a debugging aid you had =
to
> write in order to understand better linux network stack.
>
> Lets see if you manage to maintain this for a while before considerin=
g
> upstreaming it.
>

Indeed, They are not toy patches and need some time to verify their
practicability. I approximately started this project on February of
this year since I am asked to repeatedly solve some similar performance
problems or explain surprised exceptional behaviors of networking stack=
=2E
Some hard investigation works also are duplicated again and again. I
hope that skbtrace such like is able to improve this problem-solve
process.

> You said that some 'buggy' drivers set rxhash to zero, but its a vali=
d
> operation.
>
> You said 'it seems that RPS hashing can not work well for some corner
> cases', but its a known fact.
>

Em, we really are able to verify RPS imbalance by checking the last
column of /proc/net/softnet_stat, but skbtrace can give us more details
of RSS/RPS hashing. For improper RPS hashing case, it can provide more
details of what really happen in real time.

Thanks.

> Thanks
>
>
>
