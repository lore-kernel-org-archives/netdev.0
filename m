From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] include/linux/skbuff.h: using '0xffff' instead of '~0U'
Date: Mon, 03 Jun 2013 17:23:54 +0800
Message-ID: <51AC60AA.8010107@asianux.com>
References: <51A6EBC5.7040601@asianux.com> <CAHp75VfWvXkaoYQ_40idSsLYUA=YqaswnV2y-hODHjt7JMHQvQ@mail.gmail.com>
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
In-Reply-To: <CAHp75VfWvXkaoYQ_40idSsLYUA=YqaswnV2y-hODHjt7JMHQvQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/01/2013 05:05 AM, Andy Shevchenko wrote:
> On Thu, May 30, 2013 at 9:03 AM, Chen Gang <gang.chen@asianux.com> wrote:
>> >
>> > Both 'transport_header' and 'mac_header' are u16, which are never equal
>> > to '~0U'.
>> >
>> > So need use '0xffff' instead of '~0U'.
> Why not "(u16)~0" ?
> Or even better "!= USHORT_MAX"?
> 
> Or mac_header + 1 == 0, though it less clear.

It seems they are just the same as '0xffff' (are all 'magic' number).

We'd better to give a meaningful name to it just like Ben said.


Thanks.
-- 
Chen Gang

Asianux Corporation
