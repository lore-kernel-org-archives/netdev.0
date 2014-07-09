From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH RFCv2] arm64: eBPF JIT compiler
Date: Tue, 8 Jul 2014 22:11:54 -0700
Message-ID: <CABg9mcv+7qSOSKw9emq1A+JbEvrUT9k4vAHMx9pdJiy4R4ZF9A@mail.gmail.com>
References: <1404803213-10653-1-git-send-email-zlim.lnx@gmail.com>
	<CAMEtUuydrYMGdg2zNDYX4vKL0_-reF+yOPKx5hpUvy4guuVeBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuydrYMGdg2zNDYX4vKL0_-reF+yOPKx5hpUvy4guuVeBg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 8, 2014 at 2:24 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Tue, Jul 8, 2014 at 12:06 AM, Zi Shen Lim <zlim.lnx@gmail.com> wrote:
[...]
>>   Also, per discussion with Alexei, and additional suggestion from
>>   Daniel:
>>   - moved load_pointer() from net/core/filter.c into filter.h
>>     as bpf_load_pointer()
>>   which is done as a separate preparatory patch. [1]
>>
>> [1] http://patchwork.ozlabs.org/patch/366906/
>
> Just to clarify. This patch is on top of [1]

Yes, that's correct. This patch uses bpf_load_pointer() from [1].

BTW, looks like David has applied it in net-next 9f12fbe603f7
("net: filter: move load_pointer() into filter.h").

[...]
>> +               case BPF_DW:
>
> this case can be removed too.

Thanks for catching this :) I've removed it.

>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Great work. Thanks.

Thanks for your time and feedback!
