From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] bpf: arm64: lift restriction on last instruction
Date: Wed, 3 Dec 2014 18:04:52 +0000
Message-ID: <20141203180451.GR7915@arm.com>
References: <1417595881-32218-1-git-send-email-zlim.lnx@gmail.com>
 <CAMEtUuwJHC2eyOh3pD=qDXw1YbfJqx1a7W0o65n5Ur_B_TvNOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuwJHC2eyOh3pD=qDXw1YbfJqx1a7W0o65n5Ur_B_TvNOA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 03, 2014 at 03:54:32PM +0000, Alexei Starovoitov wrote:
> On Wed, Dec 3, 2014 at 12:38 AM, Zi Shen Lim <zlim.lnx@gmail.com> wrote:
> > Earlier implementation assumed last instruction is BPF_EXIT.
> > Since this is no longer a restriction in eBPF, we remove this
> > limitation.
> >
> > Per Alexei Starovoitov [1]:
> >> classic BPF has a restriction that last insn is always BPF_RET.
> >> eBPF doesn't have BPF_RET instruction and this restriction.
> >> It has BPF_EXIT insn which can appear anywhere in the program
> >> one or more times and it doesn't have to be last insn.
> >
> > [1] https://lkml.org/lkml/2014/11/27/2
> >
> > Fixes: e54bcde3d69d ("arm64: eBPF JIT compiler")
> > Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
> 
> yours is cleaner than my own attempt to fix it.
> Thanks!
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Cheers, I've applied this for 3.19.

Will
