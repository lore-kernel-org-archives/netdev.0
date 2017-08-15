From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]
 Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile
Date: Tue, 15 Aug 2017 10:36:51 -0700 (PDT)
Message-ID: <20170815.103651.1877616739706523154.davem@davemloft.net>
References: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
        <CADVnQymS_n=ihTaBCx-A6rw2Xxj264ua5xK7mKCppe5r_aR+ig@mail.gmail.com>
        <5fac1100-c7d3-85ed-8230-53e6ffb3df0a@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, mohamed.a.alrshah@ieee.org,
        netdev@vger.kernel.org, torvalds@linux-foundation.org,
        linux-kernel@vger.kernel.org, mothman@upm.edu.my,
        borhan@upm.edu.my, zurinamh@upm.edu.my
To: rdunlap@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5fac1100-c7d3-85ed-8230-53e6ffb3df0a@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 15 Aug 2017 09:41:53 -0700

> On 08/15/2017 06:51 AM, Neal Cardwell wrote:
>> On Tue, Aug 15, 2017 at 9:08 AM, mohamedalrshah
>> <mohamed.a.alrshah@ieee.org> wrote:
>> 
>>> +static void agilesdtcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
>>> +{
>>> +       struct tcp_sock *tp = tcp_sk(sk);
>>> +       struct agilesdtcp *ca = inet_csk_ca(sk);
>>> +       u32 inc_factor;
>>> +       u32 ca_inc;
>>> +       u32 current_gap, total_gap;
>> 
>> For coding style, please order local variable declarations from
>> longest to shortest line, also know as Reverse Christmas Tree Format.
> 
> Per what coding style, please?  This is not in current coding style nor in the
> netdev-FAQ exceptions.

It is the established practice, documented or not, and I enforce this for all
networking code submissions.
