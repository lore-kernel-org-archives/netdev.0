From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Linux 4.9.55 break network setup because dhcp client gets an error
Date: Thu, 12 Oct 2017 12:56:57 -0700
Message-ID: <CAM_iQpXcx3rzHf-vw_D0miPC+asUKWN8kUcXSQzgV8vMXHJpFA@mail.gmail.com>
References: <b4a1ec2d-d40d-555d-f1d6-74f96cbb405a@free.fr> <CAKocOOPvO4GjWPGVt+dUkti3=GruUz5eu3WXV8D-9fdF+KK0sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: eric.valette@free.fr, LKML <linux-kernel@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Greg KH <gregkh@linuxfoundation.org>,
        David Miller <davem@davemloft.net>, shuahkh@osg.samsung.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Shuah Khan <shuahkhan@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAKocOOPvO4GjWPGVt+dUkti3=GruUz5eu3WXV8D-9fdF+KK0sg@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev and the author Eric)

On Thu, Oct 12, 2017 at 10:57 AM, Shuah Khan <shuahkhan@gmail.com> wrote:
> On Thu, Oct 12, 2017 at 11:52 AM, Eric Valette <eric.valette@free.fr> wrote:
>> Hi,
>>
>> Just compiled a fresh 4.9.55, with same .config, same user space than 4.9.54
>> and discovered I had no network because ifup fails because dhcp cleint
>> fails. As everything is identical, 4.9.54 still works, I guess one patch in
>> net/core/... did break something.
>>
>> ifup eth0
>> Internet Systems Consortium DHCP Client 4.3.5
>> Copyright 2004-2016 Internet Systems Consortium.
>> All rights reserved.
>> For info, please visit https://www.isc.org/software/dhcp/
>>
>> Can't install packet filter program: Cannot allocate memory
>>  <=====
>> If you think you have received this message due to a bug rather
>> than a configuration issue please read the section on submitting
>> bugs on either our web page at www.isc.org or in the README file
>> before submitting a bug.  These pages explain the proper
>> process and the information we find helpful for debugging..
>>
>> exiting.
>> ifup: failed to bring up eth0
>>
>> Ps: CC me I'm not subscribed
>>
>
> Please revert commit 345c66695569db83eed100723e4df72cb54df7de
>
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Mon Oct 2 12:20:51 2017 -0700
>
>     socket, bpf: fix possible use after free
>
> This will fix the problem.
>
> thanks,
> -- Shuah
