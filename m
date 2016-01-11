From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: bump skb->users before callback invocation
Date: Mon, 11 Jan 2016 23:03:22 +0300
Message-ID: <1218671452542602@web12j.yandex.ru>
References: <CACT4Y+bKYO2XfY74tgUiOC7WotQ8DRBcMT=2yy3S=Ubz8bnj_g@mail.gmail.com>
	<20151231132633.GA30790@breakpoint.cc> <20160104.214733.921867451376206917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "dvyukov@google.com" <dvyukov@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, "fw@strlen.de" <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160104.214733.921867451376206917.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone

Thanks for fixing and quick pushing of this bug.

05.01.2016, 05:47, "David Miller" <davem@davemloft.net>:
> From: Florian Westphal <fw@strlen.de>
> Date: Thu, 31 Dec 2015 14:26:33 +0100
>
>> =9ADmitry reports memleak with syskaller program.
>> =9AProblem is that connector bumps skb usecount but might not invoke=
 callback.
>>
>> =9ASo move skb_get to where we invoke the callback.
>>
>> =9AReported-by: Dmitry Vyukov <dvyukov@google.com>
>> =9ASigned-off-by: Florian Westphal <fw@strlen.de>
>
> Applied and queued up for -stable, thanks.
