From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] net: codel: fix build errors
Date: Mon, 14 May 2012 19:37:50 +0200
Message-ID: <CA+1xoqdAzeZ2gHAakT2jA359ngSA6vAs96m0rNuXSmy6C5yQ_Q@mail.gmail.com>
References: <1337015687-17693-1-git-send-email-levinsasha928@gmail.com> <20120514103526.1f1a4399@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: edumazet@google.com, dave.taht@bufferbloat.net,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:42262 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756604Ab2ENRiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 13:38:11 -0400
In-Reply-To: <20120514103526.1f1a4399@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 7:35 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 14 May 2012 19:14:47 +0200
> Sasha Levin <levinsasha928@gmail.com> wrote:
>
>> Fix the following build error:
>>
>> net/sched/sch_fq_codel.c: In function 'fq_codel_dump_stats':
>> net/sched/sch_fq_codel.c:464:3: error: unknown field 'qdisc_stats' specified in initializer
>> net/sched/sch_fq_codel.c:464:3: warning: missing braces around initializer
>> net/sched/sch_fq_codel.c:464:3: warning: (near initialization for 'st.<anonymous>')
>> net/sched/sch_fq_codel.c:465:3: error: unknown field 'qdisc_stats' specified in initializer
>> net/sched/sch_fq_codel.c:465:3: warning: excess elements in struct initializer
>> net/sched/sch_fq_codel.c:465:3: warning: (near initialization for 'st')
>> net/sched/sch_fq_codel.c:466:3: error: unknown field 'qdisc_stats' specified in initializer
>> net/sched/sch_fq_codel.c:466:3: warning: excess elements in struct initializer
>> net/sched/sch_fq_codel.c:466:3: warning: (near initialization for 'st')
>> net/sched/sch_fq_codel.c:467:3: error: unknown field 'qdisc_stats' specified in initializer
>> net/sched/sch_fq_codel.c:467:3: warning: excess elements in struct initializer
>> net/sched/sch_fq_codel.c:467:3: warning: (near initialization for 'st')
>> make[1]: *** [net/sched/sch_fq_codel.o] Error 1
>>
>> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
>
> Which Gcc version, looks like your compiler is old.

gcc version 4.5.3 (Gentoo 4.5.3-r2 p1.1, pie-0.4.7)

This is the latest gcc provided by gentoo.
