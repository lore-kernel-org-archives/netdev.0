From: "hamid jafarian" <hamid.jafarian@gmail.com>
Subject: Re: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Tue, 28 Oct 2008 13:32:06 +0330
Message-ID: <464293e60810280302j26112754o72c1cf3ebd6a0b1f@mail.gmail.com>
References: <20081027042834.0BA69C64087@host1.ystp.ac.ir>
	 <20081028000044.GA16721@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netfilter-devel <netfilter-devel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"Jan Engelhardt" <jengelh@medozas.de>,
	"Rusty Russell" <rusty@rustcorp.com.au>,
	"Harald Welte" <laforge@gnumonks.org>,
	"Eric Leblond" <eric@inl.fr>,
	"Jozsef Kadlecsik" <kadlec@blackhole.kfki.hu>,
	"Amin Azez" <azez@ufomechanic.net>
To: "Evgeniy Polyakov" <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081028000044.GA16721@ioremap.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi, &  special thanks

On Tue, Oct 28, 2008 at 3:30 AM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
> Frankly saying your codying style is way out of expected range of
> allowed glitches, so it is quite hard to review the whole thing. Please
> update it to at least remotely match existing code.

excuse for this loosely patches...
please more explain...
do you mean my patches are too long? or ambiguous?
i 've tried to code base on "Documentation/CodingStyle".. and patch
base on "how to participate in the kernel community" documents.

the core of this framework is located at pkt_tables.c&.h (#2&#3 of
kernel patches).
iptables.c&.h are completely changed. also at the user space libiptc.c
is rewritten from scratch thus their patches are really ambiguous to
be understood..what is the best way to send this patches?
what this phrase mean: "' remotely match existing code ""?

>Also I noticed you
> do not use list iteration functions sometimes and replaces them with
> direct access to next/prev pointers, which is not a good idea.
ok, i 've used this style to free list elements.
if you mean "don't use direct access to prev/next", i 'll review my
code and will try to use list iteration function on every place that
is possible or at list use list functions and list element of
structures instead of direct access to "next/prev"..

-- 
Hamid Jafarian (hm.t)
