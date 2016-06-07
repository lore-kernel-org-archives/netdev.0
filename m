From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH net-next 1/3] arm64: bpf: implement bpf_tail_call() helper
Date: Mon, 6 Jun 2016 19:33:27 -0700
Message-ID: <CAMDttNeURoDbn_Em=uV3PC68MwRqNbS0xEe7MAiii4H-eD5QFg@mail.gmail.com>
References: <201606050700.BLJUHUk2%fengguang.wu@intel.com> <5753DA61.3000505@iogearbox.net>
 <CABg9mcv0kYvk7-wsfVR3fg0nBBDVbs0QtTiWZfGRDqq7kGeFPQ@mail.gmail.com> <5755302D.1000708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	"David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5755302D.1000708@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 6, 2016 at 1:11 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 06/06/2016 06:56 AM, Z Lim wrote:
> [...]
>>
>> How about the attached patch? Fixes compilation error on build
>> !CONFIG_BPF_SYSCALL.
>>
>> Also, should this patch be sent to net or net-next (along with this
>> series)?
>
>
> Looks good, feel free to add:
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks Daniel!

>
> I think net-next along with your series should be fine since the issue
> first appeared there. Thanks, Zi!

Sounds good. I'll include this as patch 1/4 (so it doesn't trip
kbuildbot) when I send out v2.
