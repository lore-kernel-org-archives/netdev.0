From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: Re: [PATCH 3/3] 3c59x: Use setup_timer()
Date: Sun, 28 Feb 2016 13:43:32 +0530
Message-ID: <CA+5yK5GwOVkAHqzLQ-7_W0hkGT7SzYtU1kRGSTS5VWivZqtzJg@mail.gmail.com>
References: <20160224135819.GA14426@amitoj-Inspiron-3542>
	<20160225.165218.2138194136809439003.davem@davemloft.net>
	<alpine.LFD.2.20.1602280338040.17144@lianli.shorne-pla.net>
	<CA+5yK5GF4mCZe8xeDwnj7QOz1m2xz2HOVkO59wdsBktZ3kmzYA@mail.gmail.com>
	<alpine.LFD.2.20.1602281651160.17144@lianli.shorne-pla.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: Stafford Horne <shorne@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1602281651160.17144@lianli.shorne-pla.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 28, 2016 at 1:23 PM, Stafford Horne <shorne@gmail.com> wrote:
>
>
> On Sun, 28 Feb 2016, Amitoj Kaur Chawla wrote:
>
>> On Sun, Feb 28, 2016 at 12:18 AM, Stafford Horne <shorne@gmail.com> wrote:
>> >
>> >
>> > On Thu, 25 Feb 2016, David Miller wrote:
>> >
>> >> From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
>> >> Date: Wed, 24 Feb 2016 19:28:19 +0530
>> >>
>> >>> Convert a call to init_timer and accompanying intializations of
>> >>> the timer's data and function fields to a call to setup_timer.
>> >>>
>> >>> The Coccinelle semantic patch that fixes this problem is
>> >>> as follows:
>> >>>
>> >>> // <smpl>
>> >>> @@
>> >>> expression t,f,d;
>> >>> @@
>> >>>
>> >>> -init_timer(&t);
>> >>> +setup_timer(&t,f,d);
>> >>>  ...
>> >>> -t.data = d;
>> >>> -t.function = f;
>> >>> // </smpl>
>> >>>
>> >>> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
>> >>
>> >>
>> >> Applied.
>> >
>> >
>> > Hi David, Amitoj,
>> >
>> > The patch here seemed to remove the call to add_timer(&vp->timer) which
>> > applies the expires time. Would that be an issue?
>> >
>> > -Stafford
>>
>> I'm sorry. This is my mistake. How can I rectify it now that the patch
>> is applied?
>>
>> Should I send a patch adding it back?
>
>
> I sent a patch just now which could help to restore the behavior.
>
> This is applied on top of your patch which I pulled from Dave's
> tree here:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
>
> -Stafford

Thanks!

Amitoj
