From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] arm64: bpf: add 'store immediate' instruction
Date: Wed, 11 Nov 2015 12:39:56 +0000
Message-ID: <20151111123955.GK9562@arm.com>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
 <1447195301-16757-2-git-send-email-yang.shi@linaro.org>
 <CABg9mct-_AF9+kvZ0OG_JTMHkfj+OEsR2vonrxF=yD-yA6ihQw@mail.gmail.com>
 <20151111121256.GI9562@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.net,
	Catalin Marinas <catalin.marinas@arm.com>,
	Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151111121256.GI9562@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 12:12:56PM +0000, Will Deacon wrote:
> On Tue, Nov 10, 2015 at 06:45:39PM -0800, Z Lim wrote:
> > On Tue, Nov 10, 2015 at 2:41 PM, Yang Shi <yang.shi@linaro.org> wrote:
> > > aarch64 doesn't have native store immediate instruction, such operation
> > 
> > Actually, aarch64 does have "STR (immediate)". For arm64 JIT, we can
> > consider using it as an optimization.
> 
> Yes, I'd definitely like to see that in preference to moving via a
> temporary register.

Wait a second, we're both talking rubbish here :) The STR (immediate)
form is referring to the addressing mode, whereas this patch wants to
store an immediate value to memory, which does need moving to a register
first.

So the original patch is fine.

Will
