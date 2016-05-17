From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the arm64
 tree
Date: Tue, 17 May 2016 09:12:34 +0200
Message-ID: <573AC462.7070809@iogearbox.net>
References: <20160517102441.0cfbc192@canb.auug.org.au> <CAMuHMdX8oW2M8Rr_LUHNSi9PMyEoNOdsp4MrN5z3SySjfahFmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang Shi <yang.shi@linaro.org>,
	Will Deacon <will.deacon@arm.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdX8oW2M8Rr_LUHNSi9PMyEoNOdsp4MrN5z3SySjfahFmw@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/2016 09:03 AM, Geert Uytterhoeven wrote:
[...]
> Someone's not gonna be happy with commit 6077776b5908 ("bpf: split
> HAVE_BPF_JIT into cBPF and eBPF variant") breaking the sort order again...

Wasn't aware of that. Maybe I'm missing something, but there appears
to be no throughout consistent ordering ...

[...]
         select HAVE_PERF_REGS
         select HAVE_PERF_USER_STACK_DUMP
         select HAVE_RCU_TABLE_FREE
         select HAVE_SYSCALL_TRACEPOINTS
         select IOMMU_DMA if IOMMU_SUPPORT
         select IRQ_DOMAIN
         select IRQ_FORCED_THREADING
[...]
         select RTC_LIB
         select SPARSE_IRQ
         select SYSCTL_EXCEPTION_TRACE
         select HAVE_CONTEXT_TRACKING
         select HAVE_ARM_SMCCC
[...]
