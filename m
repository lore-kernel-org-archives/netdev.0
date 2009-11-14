From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Sat, 14 Nov 2009 21:30:52 +0800
Message-ID: <412e6f7f0911140530h1fac3053v5d5fe30ceac303a1@mail.gmail.com>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
	 <20091113074508.GA6605@ff.dom.local>
	 <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
	 <20091113091825.GA7449@ff.dom.local>
	 <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
	 <20091113081553.0568296c@s6510>
	 <412e6f7f0911131528i3105648y49213143e12f2522@mail.gmail.com>
	 <20091113153229.408c889f@nehalam>
	 <412e6f7f0911131542w1029893cmd07599660b810ed5@mail.gmail.com>
	 <4AFEA830.3000101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:40767 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbZKNNaq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 08:30:46 -0500
Received: by pwi3 with SMTP id 3so2499960pwi.21
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2009 05:30:52 -0800 (PST)
In-Reply-To: <4AFEA830.3000101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 14, 2009 at 8:53 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Changli Gao a =C3=A9crit :
>> Yea, the overhead of SoftIRQ is less than kernel threads, and I'll t=
ry
>> to find a way to solve both flexibility and efficiency. Maybe I need
>> some real NIC drivers as examples. Is there a standard API to bind R=
Qs
>> of NIC to CPUs, such as ioctl or setsockopt?
>
> Thats a good question... napi is bound to a cpu, and you'll need
> things that were done by Tom Herbert in its RPS patch, to
> be able to deleguate work to remote cpus napi contexts.
>
> But if we consider RPS being close to be committed, shouldnt
> IFB use its, in order to not duplicate changes ?
>
> Or, if you prefer, once RPS is in, we dont need to change IFB, since
> RPS will already split the load to multiple cpus before entering IFB.
>
>

I had known RPS before I began my IFB work, so I added Tom to the CC
list, but I don't know if RPS will be in the mainline. Since there
isn't any core change in IFB as is in RPS, I think it is easier to
merge IFB into the mainline. If RPS is merged before IFB-MQ, I'll give
IFB-MQ up, and vice versa I think.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
