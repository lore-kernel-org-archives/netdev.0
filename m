From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Sat, 14 Nov 2009 07:42:12 +0800
Message-ID: <412e6f7f0911131542w1029893cmd07599660b810ed5@mail.gmail.com>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
	 <20091113074508.GA6605@ff.dom.local>
	 <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
	 <20091113091825.GA7449@ff.dom.local>
	 <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
	 <20091113081553.0568296c@s6510>
	 <412e6f7f0911131528i3105648y49213143e12f2522@mail.gmail.com>
	 <20091113153229.408c889f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:64949 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932549AbZKMXmI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 18:42:08 -0500
Received: by pwi3 with SMTP id 3so2276196pwi.21
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 15:42:12 -0800 (PST)
In-Reply-To: <20091113153229.408c889f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 14, 2009 at 7:32 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Sat, 14 Nov 2009 07:28:42 +0800
> Changli Gao <xiaosuo@gmail.com> wrote:
>
>> On Sat, Nov 14, 2009 at 12:15 AM, Stephen Hemminger
>>
>> It needs to send remote SoftIRQ, as Receiving Packet Steering, and w=
e
>> must support a extra interface to map load to CPUs.
>>
>
> But it still could use NAPI to avoid causing excess packet overhead.
> The softirq could be equivalent of hardirq in network device.
>

Yea, the overhead of SoftIRQ is less than kernel threads, and I'll try
to find a way to solve both flexibility and efficiency. Maybe I need
some real NIC drivers as examples. Is there a standard API to bind RQs
of NIC to CPUs, such as ioctl or setsockopt?


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
