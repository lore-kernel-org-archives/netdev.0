From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 12 Nov 2013 10:14:34 +0100
Message-ID: <87a9hagex1.fsf@natisbad.org>
References: <8761s0cqhh.fsf@natisbad.org>
	<slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	<87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, edumazet@google.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131112083633.GB10318@1wt.eu> (Willy Tarreau's message of "Tue,
	12 Nov 2013 09:36:33 +0100")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Willy Tarreau <w@1wt.eu> writes:

>> That been said, even if the driver is most probably not the only one to
>> blame here (considering the result of bisect and current thread on
>> netdev), I never managed to get the performance I have on my ReadyNAS
>> Duo v2 (i.e. 108MB/s for a file served by an Apache) with a mvneta-based
>> platform (RN102, RN104 or RN2120). Understanding why is on an already a
>> long todo list. 
>
> Yes I found that your original numbers were already quite low,

Tests for the rgression were done w/ scp, and were hence limited by the
crypto (16MB/s using arcfour128). But I also did some tests w/ a simple
wget for a file served by Apache *before* the regression and I never got
more than 60MB/s from what I recall. Can you beat that? 

> so it is also possible that you have a different problem (eg: faulty
> switch or auto-negociation problem where the switch goes to half
> duplex because the neta does not advertise nway or whatever) that is
> emphasized by the latest changes

Tested w/ back to back connections to the NAS from various hosts and
through different switch. Never saturated the link.

> I can confirm that I got this message from you on netdev so it should be OK
> now.

Good. Thanks for the info.

a+
