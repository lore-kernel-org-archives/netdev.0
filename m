From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 12 Nov 2013 16:34:24 +0100
Message-ID: <87vbzxd473.fsf@natisbad.org>
References: <8761s0cqhh.fsf@natisbad.org>
	<slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	<87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
	<87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>, edumazet@google.com,
	stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131112100126.GB23981@1wt.eu> (Willy Tarreau's message of "Tue,
	12 Nov 2013 11:01:26 +0100")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Willy Tarreau <w@1wt.eu> writes:

> On Tue, Nov 12, 2013 at 10:14:34AM +0100, Arnaud Ebalard wrote:
>> Tests for the rgression were done w/ scp, and were hence limited by the
>> crypto (16MB/s using arcfour128). But I also did some tests w/ a simple
>> wget for a file served by Apache *before* the regression and I never got
>> more than 60MB/s from what I recall. Can you beat that? 
>
> Yes, I finally picked my mirabox out of my bag for a quick test. It boots
> off 3.10.0-rc7 and I totally saturate one port (stable 988 Mbps) with even
> a single TCP stream.

Thanks for the feedback. That's interesting. What are you using for your tests
(wget, ...)? 

> With two systems, one directly connected (dockstar) and the other one via
> a switch, I get 2*650 Mbps (a single TCP stream is enough on each).
>
> I'll have to re-run some tests using a more up to date kernel, but that
> will probably not be today though.

Can you give a pre-3.11.7 kernel a try if you find the time? I started
working on RN102 during 3.10-rc cycle but do not remember if I did the
first preformance tests on 3.10 or 3.11. And if you find more time,
3.11.7 would be nice too ;-)

Cheers,

a+
