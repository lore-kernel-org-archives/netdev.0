From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH]
 Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile
Date: Tue, 15 Aug 2017 09:41:53 -0700
Message-ID: <5fac1100-c7d3-85ed-8230-53e6ffb3df0a@infradead.org>
References: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
 <CADVnQymS_n=ihTaBCx-A6rw2Xxj264ua5xK7mKCppe5r_aR+ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Mohamed Othman <mothman@upm.edu.my>,
        Borhanuddin Ali <borhan@upm.edu.my>,
        Zurina Hanapi <zurinamh@upm.edu.my>
To: Neal Cardwell <ncardwell@google.com>,
        mohamedalrshah <mohamed.a.alrshah@ieee.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQymS_n=ihTaBCx-A6rw2Xxj264ua5xK7mKCppe5r_aR+ig@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/2017 06:51 AM, Neal Cardwell wrote:
> On Tue, Aug 15, 2017 at 9:08 AM, mohamedalrshah
> <mohamed.a.alrshah@ieee.org> wrote:
> 
>> +static void agilesdtcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
>> +{
>> +       struct tcp_sock *tp = tcp_sk(sk);
>> +       struct agilesdtcp *ca = inet_csk_ca(sk);
>> +       u32 inc_factor;
>> +       u32 ca_inc;
>> +       u32 current_gap, total_gap;
> 
> For coding style, please order local variable declarations from
> longest to shortest line, also know as Reverse Christmas Tree Format.

Per what coding style, please?  This is not in current coding style nor in the
netdev-FAQ exceptions.


-- 
~Randy
