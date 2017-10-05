From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] netfilter: ipset: Convert timers to use timer_setup()
Date: Thu, 5 Oct 2017 11:15:40 -0700
Message-ID: <CAGXu5jJGiLDb1afVUsj=S=tA-WO1O-aJgmxz7706iC4QK9MxZg@mail.gmail.com>
References: <20171005005221.GA23584@beast> <alpine.DEB.2.11.1710051551460.11178@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        simran singhal <singhalsimran0@gmail.com>,
        Muhammad Falak R Wani <falakreyaz@gmail.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1710051551460.11178@blackhole.kfki.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 5, 2017 at 6:58 AM, Jozsef Kadlecsik
<kadlec@blackhole.kfki.hu> wrote:
> Hi,
>
> On Wed, 4 Oct 2017, Kees Cook wrote:
>
>> In preparation for unconditionally passing the struct timer_list pointer
>> to all timer callbacks, switch to using the new timer_setup() and
>> from_timer() to pass the timer pointer explicitly. This introduces a
>> pointer back to the struct ip_set, which is used instead of the struct
>> timer_list .data field.
>
> Please add the same changes to net/netfilter/ipset/ip_set_list.c too, in
> order to handle all ipset modules in a single patch. I don't see a way
> either to avoid the introduction of the new pointer.

Ah yes, thanks. I'll send a v2 with that included.

-Kees

-- 
Kees Cook
Pixel Security
