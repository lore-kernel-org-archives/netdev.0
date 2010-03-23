From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
	online CPUs default
Date: Tue, 23 Mar 2010 18:03:22 +0800
Message-ID: <412e6f7f1003230303l69fc142ey1581fff4c3e749be@mail.gmail.com>
References: <4BA85EA2.1090304@gmail.com> <1269329250.3043.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:40779 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab0CWKDo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 06:03:44 -0400
Received: by iwn6 with SMTP id 6so1597530iwn.4
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 03:03:43 -0700 (PDT)
In-Reply-To: <1269329250.3043.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 23, 2010 at 3:27 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 23 mars 2010 =C3=A0 14:24 +0800, Changli Gao a =C3=A9crit :
>> make distributing packets fairly among all the online CPUs default.
>>
>> Make distributing packets fairly among all the online CPUs default, =
then
>> users don't need any explicit configuration to get the benefit of RP=
S.
>>
>
> Some people want to dedicate a cpu to network interrupts, cache hits
> only, to get low latencies.
> RPS is not a win for all workloads.
>
> I think we should not change default without a knob.
>
> Didnt we discussed all this during last months ?
>

Ben Hutchings raised this question, but nobody replied with any message=
=2E

I do think distributing packets fairly among all the online CPUs will
helps most of users. I remember the smp_affinity of IRQ is the
online_cpu_mask be default.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
