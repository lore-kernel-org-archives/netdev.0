From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Tue, 20 Oct 2009 15:50:09 +0400
Message-ID: <aa79d98a0910200450n1a283f87hf946bb3b756d0bd@mail.gmail.com>
References: <200910190002.39937.denys@visp.net.lb>
	 <200910200308.57381.denys@visp.net.lb>
	 <aa79d98a0910192004g43de90d5p823293b888cf0c1d@mail.gmail.com>
	 <200910201436.50249.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <200910201436.50249.denys@visp.net.lb>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/09, Denys Fedoryschenko <denys@visp.net.lb> wrote:
> On Tuesday 20 October 2009 06:04:35 Cyrill Gorcunov wrote:
>> On 10/20/09, Denys Fedoryschenko <denys@visp.net.lb> wrote:
>> > On Tuesday 20 October 2009 00:22:39 Michal Ostrowski wrote:
>> >> I'm assuming that there was a race in us sending patches at nearly the
>> >> same
>> >> time I'm convinced now that the flush_lock can die, and the patch I
>> >> sent
>> >> out kills it.
>> >
>> > o_O
>> >
>> > I am drowning in patches. Just let me know which one to test :-)
>>
>> Oh ;) Try out latest Michal's patch (and then mine). I'll continue
>> digg this issue at next spare time slot. Thanks!
> Tried your patch, panic almost immediately
> Here is a text of panic message over netconsole
> http://www.nuclearcat.com/files/panic_pppoe3.txt
> It is  different now, before it was pppoe_device_event, now in pppoe_rcv
>
>
Thanks a lot! I'll back with new one in a couple of hours. Meanwhile i
suppose you may try Michal's patch as well.
