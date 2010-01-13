From: Daniel Borkmann <danborkmann@googlemail.com>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per
	interface
Date: Wed, 13 Jan 2010 17:53:43 +0100
Message-ID: <6f52f5b81001130853ve852e7bl1d5e6879dc4eb545@mail.gmail.com>
References: <4B4630C0.6090206@gmail.com> <4B467A4D.9070708@gmail.com>
	 <1263252108.29868.4774.camel@calx>
	 <20100111.155912.68138954.davem@davemloft.net>
	 <1263254625.29868.4777.camel@calx> <4B4BBDA5.8010808@gmail.com>
	 <4B4D1372.9060702@gmail.com>
	 <x49ljg25cr0.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Mackall <mpm@selenic.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev@oss.sgi.com
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756110Ab0AMRA6@vger.kernel.org>
In-Reply-To: <x49ljg25cr0.fsf@segfault.boston.devel.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/1/13 Jeff Moyer <jmoyer@redhat.com>:
> Daniel Borkmann <danborkmann@googlemail.com> writes:
>
>> Daniel Borkmann wrote:
>>> Matt Mackall wrote:
>>>> On Mon, 2010-01-11 at 15:59 -0800, David Miller wrote:
>>>>> From: Matt Mackall <mpm@selenic.com>
>>>>> Date: Mon, 11 Jan 2010 17:21:48 -0600
>>>>>
>>>>>> Looks pretty good. Dave?
>>>>>>
>>>>>> Acked-by: Matt Mackall <mpm@selenic.com>
>>>>> I don't like the loop for RX ARP processing.
>>>>>
>>>>> The packet contents aren't going to change, so doing basic
>>>>> packet validation inside of the "for each RX client" loop
>>>>> of arp_reply() doesn't make any sense.
>>>> True. Dan, please help our poor compilers with some manual loop
>>>> invariant motion.
>>>
>>> Okay, true. I'll fix this by tomorrow and resend the patch.
>>
>> Here the fix of the RX ARP processing routine. Content that isn't
>> going to change is out-of-loop.
>> Successfully tested on my machines.
>
> Against what tree does this patch apply? =A0It doesn't apply to Linus=
's
> git tree. =A0Also, in the future, could you use the -p option to diff=
 so
> we can see what function or data structure is being modified? =A0It r=
eally
> helps in reviewing.

As mentioned earlier in this thread... when I started developing the pa=
tch I
used 2.6.32.2 (latest stable from kernel.org), which might be already "=
old" ...
sorry for that. Ok, next time I will use -p, too. For the moment, it wa=
s diff
with -Nur. Shall I resend?

Best regards,
Daniel
