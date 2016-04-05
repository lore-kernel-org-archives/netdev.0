From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH net 4/4] lib/test_bpf: Add additional BPF_ADD tests
Date: Tue, 5 Apr 2016 22:21:47 +0530
Message-ID: <20160405165147.GC15993@naverao1-tp.in.ibm.com>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
 <9b71e280481a9f84cd7dbb9e767fd08e6f4c0aef.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
 <5703E7B2.6050706@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5703E7B2.6050706@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/04/05 09:28AM, Alexei Starovoitov wrote:
> On 4/5/16 3:02 AM, Naveen N. Rao wrote:
> >Some of these tests proved useful with the powerpc eBPF JIT port due to
> >sign-extended 16-bit immediate loads. Though some of these aspects get
> >covered in other tests, it is better to have explicit tests so as to
> >quickly tag the precise problem.
> >
> >Cc: Alexei Starovoitov <ast@fb.com>
> >Cc: Daniel Borkmann <daniel@iogearbox.net>
> >Cc: "David S. Miller" <davem@davemloft.net>
> >Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> >Cc: Michael Ellerman <mpe@ellerman.id.au>
> >Cc: Paul Mackerras <paulus@samba.org>
> >Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> 
> Makes sense. Looks like ppc jit will be using quite a bit of
> available ppc instructions. Nice.
> 
> I'm assuming all these new tests passed with x64 jit?

Yes, all these tests pass on x86_64.

- Naveen
