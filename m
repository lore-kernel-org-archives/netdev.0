From: Sharat Masetty <sharat04@gmail.com>
Subject: Re: IPV6 routing problem
Date: Thu, 23 Jan 2014 00:15:29 -0700
Message-ID: <CAJzFV34FhudmwOPY1q9SUtagb8rUuQanrAqt_+cOyETFsLcxqw@mail.gmail.com>
References: <CAJzFV37rPo6trvCwWyErchen_MvTzqabSU+BE3JZjNXT5-5H7Q@mail.gmail.com>
	<20140122070759.GB28225@order.stressinduktion.org>
	<20140122071101.GC28225@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Sharat Masetty <sharat04@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:46131 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbaAWHPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 02:15:30 -0500
Received: by mail-ve0-f178.google.com with SMTP id oy12so876592veb.37
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 23:15:29 -0800 (PST)
In-Reply-To: <20140122071101.GC28225@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately toggling this config setting CONFIG_IPV6_ROUTER_PREF did
not help, I see the same problem in both cases.
The kernel version I am using is 3.10.0.

Thanks for confirming that this is a non issue on 3.13 kernel version.
Would you happen to know which patch would have potentially fixed this
issue?


On Wed, Jan 22, 2014 at 12:11 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Jan 22, 2014 at 08:07:59AM +0100, Hannes Frederic Sowa wrote:
>> Hi!
>>
>> On Tue, Jan 21, 2014 at 06:41:58PM -0700, Sharat Masetty wrote:
>> >  I have an IPV6 routing problem that has only surfaced on a 3.10
>> > kernel version. This problem is not seen on 3.4 kernel. I will keep
>> > the problem statement as brief as possible.
>>
>> Could you do me a favor and test this on a recent 3.13 kernel? Thanks!
>> Please also state the specific kernel version (I guess you use one).
>
> +stable.
>
> A quick test worked for me. Maybe you could try with CONFIG_IPV6_ROUTER_PREF
> enabled and one time with it disabled.
>
> We should make this knob a runtime setting soon...
>
> Thanks,
>
>   Hannes
>
