From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] ppc: ebpf/jit: Implement JIT compiler for extended
 BPF
Date: Thu, 9 Jun 2016 11:37:52 +0530
Message-ID: <20160609060752.GQ18654@naverao1-tp.localdomain>
References: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <CACbG308O_+hXHuUo_opRPeLXLmoZj=gzEnMrwhwidf0m3+SOTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Matt Evans <matt@ozlabs.org>, Alexei Starovoitov <ast@fb.com>,
	netdev@vger.kernel.org, Denis Kirjanov <kda@linux-powerpc.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>,
	linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: Nilay Vaish <nilayvaish@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACbG308O_+hXHuUo_opRPeLXLmoZj=gzEnMrwhwidf0m3+SOTQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/06/08 10:19PM, Nilay Vaish wrote:
> Naveen, can you point out where in the patch you update the variable:
> idx, a member of codegen_contex structure?  Somehow I am unable to
> figure it out.  I can only see that we set it to 0 in the
> bpf_int_jit_compile function.  Since all your test cases pass, I am
> clearly overlooking something.

Yes, that's being done in bpf_jit.h (see the earlier patches in the 
series). All the PPC_*() instruction macros are defined to EMIT() the 
respective powerpc instruction encoding.  EMIT() translates to 
PLANT_INSTR(), which actually increments idx.

- Naveen
