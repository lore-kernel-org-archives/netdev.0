From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [PATCH] arm64: bpf: fix JIT stack setup
Date: Tue, 10 Nov 2015 11:46:42 -0800
Message-ID: <564249A2.1070903@linaro.org>
References: <1446874577-14539-1-git-send-email-yang.shi@linaro.org>	<20151108022726.GB39441@ast-mbp.thefacebook.com>	<CABg9mcv8W4_pvkEQKtjBPi5ycMgLPksYoPtYnGr6tdcb5ER8YQ@mail.gmail.com>	<5640E135.2020007@linaro.org> <CABg9mcvACuVK2=GBbnur94CsckN2TXRCCiXhX7A8jYQ7arMM+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABg9mcvACuVK2=GBbnur94CsckN2TXRCCiXhX7A8jYQ7arMM+Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/9/2015 12:00 PM, Z Lim wrote:
> On Mon, Nov 9, 2015 at 10:08 AM, Shi, Yang <yang.shi@linaro.org> wrote:
>> I added it to stay align with ARMv8 AAPCS to maintain the correct FP during
>> function call. It makes us get correct stack backtrace.
>>
>> I think we'd better to keep compliant with ARMv8 AAPCS in BPF JIT prologue
>> too.
>>
>> If nobody thinks it is necessary, we definitely could remove that change.
>
> Oh no, I don't think anyone will say it's unnecessary!
> I agree the A64_FP-related change is a good idea, so stack unwinding works.
>
> How about splitting this into two patches? One for the BPF-related
> bug, and another for A64 FP-handling.

I'm not sure if this is a good approach or not. IMHO, they are kind of 
atomic. Without A64 FP-handling, that fix looks incomplete and 
introduces another problem (stack backtrace).

Thanks,
Yang

>
> Thanks again for tracking this down and improving things overall for arm64 :)
>
>>
>> Thanks,
>> Yang
>>
>>
