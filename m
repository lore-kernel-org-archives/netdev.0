From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/2] bpf samples: fix compiler errors with sockex2 and
 sockex3
Date: Sat, 24 Sep 2016 03:25:56 -0400
Message-ID: <20160924072524.GA48029@ast-mbp>
References: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 24, 2016 at 02:10:04AM +0530, Naveen N. Rao wrote:
> These samples fail to compile as 'struct flow_keys' conflicts with
> definition in net/flow_dissector.h. Fix the same by renaming the
> structure used in the sample.
> 
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Thanks for the fix.
Acked-by: Alexei Starovoitov <ast@kernel.org>
