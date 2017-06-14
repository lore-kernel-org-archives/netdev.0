From: Dison River <pwn2river@gmail.com>
Subject: Re: kernel BUG at net/ipv4/tcp_output.c:2748!
Date: Wed, 14 Jun 2017 14:25:17 +0800
Message-ID: <CAJsXRPFxhULGDBgbHQHit2_x6URO3FQ8C6XrZoqRogSOK8D5hA@mail.gmail.com>
References: <CAJsXRPG5_0q95s_p7yRKT2crU-ghgTMx6ki8mRSg=MkJ58becA@mail.gmail.com>
 <20170613130246.GA23325@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        jmorris@namei.org, yoshfuji@linux-ipv6.org,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613130246.GA23325@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:
I tested the PoC on v3.18 ~ v4.11,all the kenel have crashed.But,The
v4.12-rc4 version is not affected
thanks.

2017-06-13 21:02 GMT+08:00 Greg KH <greg@kroah.com>:
> On Tue, Jun 13, 2017 at 07:39:00PM +0800, Dison River wrote:
>> Hi
>>    I've got the following error report while fuzzing the kernel with
>> syzkaller on
>> linux-4.11.0-rc3.
>
> 4.11-rc3 is pretty old now, can you try 4.12-rc4 for this?
>
> thanks,
>
> greg k-h
