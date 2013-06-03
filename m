From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] include/linux/skbuff.h: using '0xffff' instead of '~0U'
Date: Mon, 03 Jun 2013 18:51:50 +0800
Message-ID: <51AC7546.4010002@asianux.com>
References: <51A6EBC5.7040601@asianux.com> <CAHp75VfWvXkaoYQ_40idSsLYUA=YqaswnV2y-hODHjt7JMHQvQ@mail.gmail.com> <51AC60AA.8010107@asianux.com> <CAHp75Vc19Kii7_TF+9aF4ZeKAa4_92DCVL+u1duZDTu38o2qsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, Pravin Shelar <pshelar@nicira.com>,
	mgorman@suse.de, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75Vc19Kii7_TF+9aF4ZeKAa4_92DCVL+u1duZDTu38o2qsw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/03/2013 06:14 PM, Andy Shevchenko wrote:
> On Mon, Jun 3, 2013 at 12:23 PM, Chen Gang <gang.chen@asianux.com> wrote:
>> On 06/01/2013 05:05 AM, Andy Shevchenko wrote:
> 
>>> Why not "(u16)~0" ?
>> We'd better to give a meaningful name to it just like Ben said.
> 
> Yeah, you could give a name, though I don't see this needs for
> constants like (u16)~0. It's a usual way to mark some values
> uninitialized.
> Just an example from kernel:
> 
>         /* This is limited by 16 bit "slot" numbers,
>          * and by available on-disk context storage.
>          *
>          * Also (u16)~0 is special (denotes a "free" extent).
> 

After "fgrep -rn 'u16' * | fgrep '~0'", it seems better to define a
meaningful macro for it (e.g. "#define SKB_HEADER_WAS_UNSET    0xffff").


Thanks.
-- 
Chen Gang

Asianux Corporation
