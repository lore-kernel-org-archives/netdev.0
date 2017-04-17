From: Alexander Aring <aar@pengutronix.de>
Subject: Re: skb_over_panic using UDP and 6lowpan / fakelb
Date: Mon, 17 Apr 2017 15:25:48 +0200
Message-ID: <0ddbdbde-8610-0ea5-bae2-4ec2702927dc@pengutronix.de>
References: <56012235-e1d0-1e5e-840a-cc8d5938c380@ntnu.no>
 <CAM_iQpWqQj3FLpBLE1Z+==Z7tJGXHyHXTvLmKRCNjyc=vtQvnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Palma <david.palma@ntnu.no>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        stefan@osg.samsung.com, linux-wpan@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58031 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753348AbdDQNZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 09:25:54 -0400
In-Reply-To: <CAM_iQpWqQj3FLpBLE1Z+==Z7tJGXHyHXTvLmKRCNjyc=vtQvnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

sorry for the late reply.

On 04/03/2017 07:29 PM, Cong Wang wrote:
> (Cc'ing netdev and maintainers)
> 
> On Mon, Mar 27, 2017 at 2:16 AM, David Palma <david.palma@ntnu.no> wrote:
>>
>> Hi,
>>
>> Sending a simple UDP packet (39 bytes long), over a 6lowpan interface
>> (using fakelb), creates a kernel panic (skb_over_panic).
>>
>> Steps to reproduce, and more details, can be found in:
>> https://github.com/PalmaITEM/6lowpan-skb_over_panic
>>
>> This bug has been reported in
>> https://bugzilla.kernel.org/show_bug.cgi?id=195059
>>
>> I have found that lengths around 39 bytes can also trigger this
>> behaviour and that longer packets are handled without problem.
>>
>> Verified in:
>>
>> - Linux version 4.9.0-0.bpo.2-amd64 (debian-kernel@lists.debian.org)
>> (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Debian 4.9.13-1~bpo8+1
>> (2017-02-27)
>> - Linux version 4.10.4-1-ARCH (builduser@tobias) (gcc version 6.3.1
>> 20170306 (GCC) ) #1 SMP PREEMPT Sat Mar 18 19:39:18 CET 2017
>>
>>
>> I am not familiar with the process of reporting kernel bugs, so
>> apologies beforehand. I am also available to provide any missing
>> information.
>>

I will try to reproduce the failure with an x86_64 qemu virtual machine.
Myself I use a 32 Bit qemu machine because I have a dependency on
userspace software which use x86 assembler (somebody should change it to
setjmp/longjmp)... it's the RIOT-OS native plattform. I use some cross
compiling environment which doesn't support multilib yet, so I used
always 32 Bit.

btw: the github stuff is very useful and thanks for the hard work! I am
on it to reproduce it. I will report when I have more information.

- Alex
