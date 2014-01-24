From: Sharat Masetty <sharat04@gmail.com>
Subject: Re: IPV6 routing problem
Date: Fri, 24 Jan 2014 11:50:35 -0700
Message-ID: <CAJzFV34vJTCV+-rwH+TE1oB0qiUw1PuqgAWpm8U1Xe_xAv-_BA@mail.gmail.com>
References: <CAJzFV37rPo6trvCwWyErchen_MvTzqabSU+BE3JZjNXT5-5H7Q@mail.gmail.com>
	<20140122070759.GB28225@order.stressinduktion.org>
	<20140122071101.GC28225@order.stressinduktion.org>
	<CAJzFV34FhudmwOPY1q9SUtagb8rUuQanrAqt_+cOyETFsLcxqw@mail.gmail.com>
	<CD36411A-7584-48B1-A406-E1584B3D32DD@sekil.fr>
	<20140124135932.GR7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Emmanuel Thierry <ml@sekil.fr>,
	Sharat Masetty <sharat04@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f174.google.com ([209.85.128.174]:35079 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbaAXSug convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 13:50:36 -0500
Received: by mail-ve0-f174.google.com with SMTP id pa12so2164468veb.5
        for <netdev@vger.kernel.org>; Fri, 24 Jan 2014 10:50:36 -0800 (PST)
In-Reply-To: <20140124135932.GR7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you Emmanuel and Hannes, I went through the thread and the
suggested fix and it definitely makes sense. I will apply the fix and
test it out.

A general question, Can you suggest a good reference documentation to
understand the Linux kernel IPV6 routing and neighboring subsystem
better? The O Reilly book does not have much about IPV6.

Thanks
Sharat

On Fri, Jan 24, 2014 at 6:59 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fri, Jan 24, 2014 at 10:36:54AM +0100, Emmanuel Thierry wrote:
>> Hello,
>>
>> Le 23 janv. 2014 =C3=A0 08:15, Sharat Masetty a =C3=A9crit :
>>
>> > Unfortunately toggling this config setting CONFIG_IPV6_ROUTER_PREF=
 did
>> > not help, I see the same problem in both cases.
>> > The kernel version I am using is 3.10.0.
>> >
>> > Thanks for confirming that this is a non issue on 3.13 kernel vers=
ion.
>> > Would you happen to know which patch would have potentially fixed =
this
>> > issue?
>>
>> Your problem looks like the following one :
>> http://marc.info/?l=3Dlinux-netdev&m=3D137280268407054&w=3D2
>>
>> Which has been fixed in 3.10.4, and 3.11+
>
> Yes, that could very well be the case. We resolve the gateway while
> inserting the route (if not on-link), and it may not be available
> because of missing probes or no traffic went to it, yet. Thanks for
> looking after this, Emmanuel.
>
> I really recommend using the stable kernels btw. instead of the vania=
lla
> point zero releases.
>
> Thanks,
>
>   Hannes
>
