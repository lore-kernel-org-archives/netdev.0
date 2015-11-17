From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 2/2] arm64: bpf: make BPF prologue and epilogue
 align with ARM64 AAPCS
Date: Tue, 17 Nov 2015 11:51:44 -0500 (EST)
Message-ID: <20151117.115144.1827467904902947864.davem@davemloft.net>
References: <1447713335-29707-1-git-send-email-yang.shi@linaro.org>
	<CABg9mcvh+SLK-1iF28pCQgXt5WM_H4tH3ntgKSkMHCyMygThgw@mail.gmail.com>
	<20151117044145.GA71069@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zlim.lnx@gmail.com, yang.shi@linaro.org, ast@kernel.org,
	daniel@iogearbox.net, catalin.marinas@arm.com, will.deacon@arm.com,
	xi.wang@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: alexei.starovoitov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151117044145.GA71069@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 16 Nov 2015 20:41:46 -0800

> On Mon, Nov 16, 2015 at 08:37:11PM -0800, Z Lim wrote:
>> On Mon, Nov 16, 2015 at 2:35 PM, Yang Shi <yang.shi@linaro.org> wrote:
>> > Save and restore FP/LR in BPF prog prologue and epilogue, save SP to FP
>> > in prologue in order to get the correct stack backtrace.
> ...
>> > CC: Zi Shen Lim <zlim.lnx@gmail.com>
>> > CC: Xi Wang <xi.wang@gmail.com>
>> > Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> 
>> Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>
> 
> great that it's finalized.
> Yang, please resubmit both patches to netdev as fresh submission so it
> gets picked up by patchwork.

He doesn't need to, I applied patch #1 independently the other day while
the details of #2 were being worked out.
