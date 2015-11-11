From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH] arm64: bpf: fix JIT stack setup
Date: Tue, 10 Nov 2015 19:11:12 -0800
Message-ID: <CABg9mct8EnLAZoc5YyM5DFhw1PhdyTysxwsHiq9H5pNXh8ChLw@mail.gmail.com>
References: <1446874577-14539-1-git-send-email-yang.shi@linaro.org>
	<20151108022726.GB39441@ast-mbp.thefacebook.com>
	<CABg9mcv8W4_pvkEQKtjBPi5ycMgLPksYoPtYnGr6tdcb5ER8YQ@mail.gmail.com>
	<5640E135.2020007@linaro.org>
	<CABg9mcvACuVK2=GBbnur94CsckN2TXRCCiXhX7A8jYQ7arMM+Q@mail.gmail.com>
	<564249A2.1070903@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.net,
	Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: "Shi, Yang" <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564249A2.1070903@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2015 at 11:46 AM, Shi, Yang <yang.shi@linaro.org> wrote:
> On 11/9/2015 12:00 PM, Z Lim wrote:
>>
>> How about splitting this into two patches? One for the BPF-related
>> bug, and another for A64 FP-handling.
>
> I'm not sure if this is a good approach or not. IMHO, they are kind of
> atomic. Without A64 FP-handling, that fix looks incomplete and introduces
> another problem (stack backtrace).
>

The first, even on its own, doesn't make things worse, only better.
The second, which we agree needs to be fixed also, addresses a different issue.

Either way, please also note that these patches fix the original
implementation. We do want -stable to pick these up.

Suggestions for the diagram:
- As an enhancement, would you mind showing the A64_FP also?
- Please revisit "+64:"
