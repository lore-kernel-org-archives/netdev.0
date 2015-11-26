From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in sock_wake_async
Date: Thu, 26 Nov 2015 09:09:46 -0800
Message-ID: <1448557786.24696.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	 <CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	 <87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	 <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	 <87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
	 <1448471494.24696.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a8q23s2a.fsf@doppelsaurus.mobileactivedefense.com>
	 <1448473891.24696.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87610q3pjg.fsf@doppelsaurus.mobileactivedefense.com>
	 <1448476744.24696.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87y4dl3m5c.fsf@doppelsaurus.mobileactivedefense.com>
	 <1448481002.24696.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448483017.24696.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87two93ig8.fsf@doppelsaurus.mobileactivedefense.com>
	 <1448489350.24696.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448490732.1842763.450231537.5358AF37@webmail.messagingengine.com>
	 <1448491414.24696.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448491950.1848115.450243417.726E2DCB@webmail.messagingengine.com>
	 <87r3jcx4w7.fsf@stressinduktion.org>
	 <1448553090.24696.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448557398.912656.450874953.4CA824F0@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448557398.912656.450874953.4CA824F0@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-11-26 at 18:03 +0100, Hannes Frederic Sowa wrote:

> My rationale was like this: we already have rcu to free the wq, so we
> don't add any more callbacks as current code. sock_alloc is right now
> 1136 bytes, which is huge, like 18 cachelines. I wouldn't think it does
> matter a lot as we thrash anyway. tcp_sock is like 45 cachelines right
> now, hui.

Again, these speculations are really killing me.

Can you wait I send my patches ?

They work just great, and there is no risk of perf regression with added
RCU freeing of inodes :(

It is Thanks Giving in the US, vacation time.

Thanks.
