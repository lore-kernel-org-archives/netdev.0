From: Massimo Sala <massimo.sala.71@gmail.com>
Subject: Re: sysctl, argument parsing, possible bug
Date: Tue, 1 Aug 2017 23:34:09 +0200
Message-ID: <CAKv20-VFcdZti=4a6QzVJH0wAYGpqo2umktRPr19tv+btSZY_w@mail.gmail.com>
References: <CAKv20-VuR4J0PJOOfsRmEPMhB+vKYMdPsp5wDgVkoYwrHxgLGw@mail.gmail.com>
 <CAM_iQpXtHACnD8kmmHd4bcg+Khy5Y0K=HMmc08avTSHov4zN1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXtHACnD8kmmHd4bcg+Khy5Y0K=HMmc08avTSHov4zN1A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do you confirm it is a sysctl parsing bug ?

Bosybox handles these cases, so I think also standalone sysctl have to.

Or at least someone must update sysctl docs / MAN about this.

Best regards, Sala


On 01/08/2017, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Aug 1, 2017 at 1:47 PM, Massimo Sala <massimo.sala.71@gmail.com>
> wrote:
>> cat /proc/sys/net/ipv4/conf/eth0.100/forwarding
>> 0
>>
>> sysctl net.ipv4.conf.eth0.100.forwarding
>> error: "net.ipv4.conf.eth0.100.forwarding" is an unknown key
>>
>
> Use echo instead, sysctl doesn't understand eth0.100
> is a netdev name, sigh.
>
