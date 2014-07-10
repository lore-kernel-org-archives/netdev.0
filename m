From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFCv2] arm64: eBPF JIT compiler
Date: Thu, 10 Jul 2014 11:51:08 +0200
Message-ID: <CAMEtUuwuQzYknOm4qqYFa2By=zCOpkk4_zp=_2BuPavg-rPc-A@mail.gmail.com>
References: <1404803213-10653-1-git-send-email-zlim.lnx@gmail.com>
	<20140709130017.GL9485@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140709130017.GL9485@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 9, 2014 at 3:00 PM, Will Deacon <will.deacon@arm.com> wrote:
> On Tue, Jul 08, 2014 at 08:06:53AM +0100, Zi Shen Lim wrote:
>>
>> 1. Implement remaining classes of eBPF instructions: ST|MEM, STX|XADD
>>    which currently do not have corresponding test cases in test_bpf.
>
> I can help out with atomics, if you need it. Are the memory barrier
> semantics well-defined for eBPF?

There are no barrier or cmpxchg instructions in eBPF, since such use case
doesn't exist yet. There is only xadd that is equivalent to atomic_add
which can be JITed as exclusive load/store on arm64.
