From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Mon, 23 Jun 2014 18:17:55 +0800
Message-ID: <53A7FED3.4@gmail.com>
References: <20140506155703.GA20391@cloud>	<20140506.115941.428706504757835279.davem@davemloft.net>	<20140506164108.GA20536@cloud>	<20140506.131643.994244006906866938.davem@davemloft.net>	<20140506175547.GE20776@cloud> <CAM_iQpUgj7BqpzRL070DEGQ32SWwN68BRgM5DtFqvBLjGGOLQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUgj7BqpzRL070DEGQ32SWwN68BRgM5DtFqvBLjGGOLQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2014 02:33 AM, Cong Wang wrote:
> On Tue, May 6, 2014 at 10:55 AM,  <josh@joshtriplett.org> wrote:
>> On Tue, May 06, 2014 at 01:16:43PM -0400, David Miller wrote:
>>> From: josh@joshtriplett.org
>>> Date: Tue, 6 May 2014 09:41:08 -0700
>>>
>>>> Every KB of RAM costs real money and SoC die area (for eDRAM/eSRAM).
>>> Another poster commented that 16MB of DRAM would be cheaper than
>>> the 2MB of ram you have on these boards, probably one that fits
>>> your size profile is available as well.
>>>
>>> 2MB is just a rediculous restriction.
>> Embedded systems experts disagree with you there; there *are* systems
>> where the most cost-efficient approach is a few MB (or a few hundred KB)
>> of non-discrete memory.  We're not talking about socketed memory or even
>> soldered-down memory; we're talking about entire systems that fit on a
>> small SoC die.  The space not used by that extra RAM may well be better
>> spent on CPU optimizations, or some other integrated component.
>>
>> Such boards will be built, and many of them will run Linux, despite your
>> incredulity.  When you're building millions of a board, it's well worth
>> optimizing software to eliminate components from the bill of materials.
> So why bothers 3.15+ Linux kernel? Why not use an old kernel e.g. 2.4.x?
> 2.4.x kernel doesn't have so many new features you want to get rid of here.
Maybe 2.4.x kernel doesn't have so many new features that we want to use 
here.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
