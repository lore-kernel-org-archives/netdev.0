From: Cong Wang <cwang@twopensource.com>
Subject: Re: kernel panic in 4.2.3, rb_erase in sch_fq
Date: Tue, 3 Nov 2015 14:06:05 -0800
Message-ID: <CAHA+R7MNxEkMfyQa56d0HRk2HxeqsduUfM3BkBh=Oxm2yNBVaA@mail.gmail.com>
References: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 2, 2015 at 6:11 AM, Denys Fedoryshchenko
<nuclearcat@nuclearcat.com> wrote:
> Hi!
>
> Actually seems i was getting this panic for a while (once per week) on
> loaded pppoe server, but just now was able to get full panic message.
> After checking commit logs on sch_fq.c i didnt seen any fixes, so probably
> upgrading to newer kernel wont help?


Can you share your `tc qdisc show dev xxxx` with us? And how to reproduce
it? I tried to setup htb+fq and then flip the interface back and forth
but I don't
see any crash.

Thanks.
