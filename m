From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Linux 4.4-rc4 regression, bisected to "net: fix sock_wake_async()
 rcu protection"
Date: Thu, 31 Dec 2015 15:02:46 -0800
Message-ID: <CA+55aFwd5-TKctagqEinX_RP_n8YpVcK1s9MeLeK0DZaXyq51A@mail.gmail.com>
References: <CALCETrUHFDdfPymKfD2TJHL6w-C5dc675xuJfk=c=-twsPZqqA@mail.gmail.com>
	<8760zgnpe0.fsf@gmail.com>
	<1451483700.8255.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolai Stange <nicstange@gmail.com>,
	Andy Lutomirski <luto@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451483700.8255.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2015 at 5:55 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-12-30 at 12:32 +0100, Nicolai Stange wrote:
>>
>> Please have a look at https://lkml.kernel.org/g/87ege73bma.fsf@gmail.com
>>
>> I ran into the same issue and this one fixes it for me.
>
> Right, and the ozlabs pointers for this were :
> v2:
> https://patchwork.ozlabs.org/patch/561553/

Ok, that's merged into my tree through the networking merge today.

Andy, if you still see it with current -git, holler.

               Linus
