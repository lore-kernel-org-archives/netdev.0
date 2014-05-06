From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 11:33:11 -0700
Message-ID: <CAM_iQpUgj7BqpzRL070DEGQ32SWwN68BRgM5DtFqvBLjGGOLQA@mail.gmail.com>
References: <20140506155703.GA20391@cloud>
	<20140506.115941.428706504757835279.davem@davemloft.net>
	<20140506164108.GA20536@cloud>
	<20140506.131643.994244006906866938.davem@davemloft.net>
	<20140506175547.GE20776@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:60808 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbaEFSdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 14:33:11 -0400
In-Reply-To: <20140506175547.GE20776@cloud>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2014 at 10:55 AM,  <josh@joshtriplett.org> wrote:
> On Tue, May 06, 2014 at 01:16:43PM -0400, David Miller wrote:
>> From: josh@joshtriplett.org
>> Date: Tue, 6 May 2014 09:41:08 -0700
>>
>> > Every KB of RAM costs real money and SoC die area (for eDRAM/eSRAM).
>>
>> Another poster commented that 16MB of DRAM would be cheaper than
>> the 2MB of ram you have on these boards, probably one that fits
>> your size profile is available as well.
>>
>> 2MB is just a rediculous restriction.
>
> Embedded systems experts disagree with you there; there *are* systems
> where the most cost-efficient approach is a few MB (or a few hundred KB)
> of non-discrete memory.  We're not talking about socketed memory or even
> soldered-down memory; we're talking about entire systems that fit on a
> small SoC die.  The space not used by that extra RAM may well be better
> spent on CPU optimizations, or some other integrated component.
>
> Such boards will be built, and many of them will run Linux, despite your
> incredulity.  When you're building millions of a board, it's well worth
> optimizing software to eliminate components from the bill of materials.

So why bothers 3.15+ Linux kernel? Why not use an old kernel e.g. 2.4.x?
2.4.x kernel doesn't have so many new features you want to get rid of here.
