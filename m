From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCHv2,1/7] ppc bpf/jit: Disable classic BPF JIT on ppc64le
Date: Thu, 23 Jun 2016 19:26:27 +1000 (AEST)
Message-ID: <3rZx0z6BQqz9t1H@ozlabs.org>
References: <24a2db8c1ed97008426e8093bc83165a6a237d1c.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	stable@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <24a2db8c1ed97008426e8093bc83165a6a237d1c.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-22-06 at 16:25:01 UTC, "Naveen N. Rao" wrote:
> Classic BPF JIT was never ported completely to work on little endian
> powerpc. However, it can be enabled and will crash the system when used.
> As such, disable use of BPF JIT on ppc64le.
> 
> Reported-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> Acked-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>

Applied to powerpc fixes, thanks.

https://git.kernel.org/powerpc/c/844e3be47693f92a108cb1fb3b

cheers
