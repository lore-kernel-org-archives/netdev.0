From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 2/2] Netfilter: xt_LOG: Add timestamp support
Date: Wed, 15 Feb 2012 18:16:12 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1202151815270.15357@frira.zrqbmnf.qr>
References: <1329314115-6899-1-git-send-email-richard@nod.at>  <1329314115-6899-2-git-send-email-richard@nod.at> <1329314492.2437.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F3BBC11.1030308@nod.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rostedt@goodmis.org,
	pablo@netfilter.org, basti@b-bl.de
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F3BBC11.1030308@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2012-02-15 15:07, Richard Weinberger wrote:
>>> +		struct timespec tv;
>>> +		unsigned int msec;
>>> +
>>> +		getnstimeofday(&tv);
>>> +		msec = tv.tv_nsec / NSEC_PER_MSEC;
>>> +		sb_add(m, "TIMESTAMP=%li.%03li ", tv.tv_sec, msec);
>>
>> Since you want to use this temp variable "unsigned int msec" (I have no
>> idea why...), you must change printf format accordingly : %03u instead
>> of %03li
>
> *grml*.
> I'll remove the temp variable and use %03u.

Why not just print the nsecs directly (with %09 of course)?
