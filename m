From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Tue, 28 Oct 2008 13:07:38 +0100
Message-ID: <4907008A.6050808@trash.net>
References: <20081027042834.0BA69C64087@host1.ystp.ac.ir> <20081028000044.GA16721@ioremap.net> <464293e60810280302j26112754o72c1cf3ebd6a0b1f@mail.gmail.com> <20081028104346.GA31146@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hamid jafarian <hamid.jafarian@gmail.com>,
	Netfilter-devel <netfilter-devel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jan Engelhardt <jengelh@medozas.de>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Harald Welte <laforge@gnumonks.org>,
	Eric Leblond <eric@inl.fr>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Amin Azez <azez@ufomechanic.net>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081028104346.GA31146@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hi.
> 
> On Tue, Oct 28, 2008 at 01:32:06PM +0330, hamid jafarian (hamid.jafarian@gmail.com) wrote:
>> excuse for this loosely patches...
>> please more explain...
>> do you mean my patches are too long? or ambiguous?
>> i 've tried to code base on "Documentation/CodingStyle".. and patch
>> base on "how to participate in the kernel community" documents.
>>
>> the core of this framework is located at pkt_tables.c&.h (#2&#3 of
>> kernel patches).
>> iptables.c&.h are completely changed. also at the user space libiptc.c
>> is rewritten from scratch thus their patches are really ambiguous to
>> be understood..what is the best way to send this patches?
>> what this phrase mean: "' remotely match existing code ""?
> 
> I mean just coding style: spaces, braces, parentheses, function names
> like __something_small_AND_CAPITAL. checkpatch.pl may help, although imo
> it should not be followed strickly. It will much simpler to review changes.

I think these patches are a lost cause. Besides the fact that they
move things to the kernel instead of to userspace, they

- break the existing interface
- do not use netlink
- are a drop-in replacement instead of incremental changes or a
   completely new implementation
- fix only a very small part of the problems of the current
   iptables design

I've asked Hamid to post these patches to see if there were any
useful incremental changes that would make sense to apply to
iptables, but it seems to come down to moving userspace to kernel
to support incremental changes.
