From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [PATCH V4 2/2] arm64: bpf: make BPF prologue and epilogue align
 with ARM64 AAPCS
Date: Mon, 16 Nov 2015 20:43:52 -0800
Message-ID: <564AB088.8030903@linaro.org>
References: <CABg9mcvomep=M1As_Vj=XuTNk=jiGwXQqQWbjotMXP2csKX=Bg@mail.gmail.com> <1447713335-29707-1-git-send-email-yang.shi@linaro.org> <CABg9mcvh+SLK-1iF28pCQgXt5WM_H4tH3ntgKSkMHCyMygThgw@mail.gmail.com> <20151117044145.GA71069@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Z Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151117044145.GA71069@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/16/2015 8:41 PM, Alexei Starovoitov wrote:
> On Mon, Nov 16, 2015 at 08:37:11PM -0800, Z Lim wrote:
>> On Mon, Nov 16, 2015 at 2:35 PM, Yang Shi <yang.shi@linaro.org> wrote:
>>> Save and restore FP/LR in BPF prog prologue and epilogue, save SP to FP
>>> in prologue in order to get the correct stack backtrace.
> ...
>>> CC: Zi Shen Lim <zlim.lnx@gmail.com>
>>> CC: Xi Wang <xi.wang@gmail.com>
>>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>>
>> Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>
>
> great that it's finalized.
> Yang, please resubmit both patches to netdev as fresh submission so it
> gets picked up by patchwork.

OK, btw the first one has been applied by David.

Yang

>
