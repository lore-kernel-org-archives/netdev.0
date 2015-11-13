From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH 1/2] arm64: bpf: add 'store immediate' instruction
Date: Thu, 12 Nov 2015 19:45:07 -0800
Message-ID: <CABg9mcsQxiK8ZJdVqULiU7M0i8aPcqmgkYaRwKeiCZNsmbNH1g@mail.gmail.com>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
	<1447195301-16757-2-git-send-email-yang.shi@linaro.org>
	<CABg9mct-_AF9+kvZ0OG_JTMHkfj+OEsR2vonrxF=yD-yA6ihQw@mail.gmail.com>
	<20151111121256.GI9562@arm.com>
	<20151111123955.GK9562@arm.com>
	<5644E97B.6050203@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Will Deacon <will.deacon@arm.com>,
	Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.net,
	Catalin Marinas <catalin.marinas@arm.com>,
	Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: "Shi, Yang" <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5644E97B.6050203@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 11:33 AM, Shi, Yang <yang.shi@linaro.org> wrote:
> On 11/11/2015 4:39 AM, Will Deacon wrote:
>>
>> Wait a second, we're both talking rubbish here :) The STR (immediate)
>> form is referring to the addressing mode, whereas this patch wants to
>> store an immediate value to memory, which does need moving to a register
>> first.
>
>
> Yes, the immediate means immediate offset for addressing index. Doesn't mean
> to store immediate to memory.
>
> I don't think any load-store architecture has store immediate instruction.
>

Indeed. Sorry for the noise.

Somehow Will caught a whiff of whatever I was smoking then :)
