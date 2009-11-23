From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
	hints
Date: Mon, 23 Nov 2009 15:32:57 +0800
Message-ID: <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755102AbZKWHcx@vger.kernel.org>
In-Reply-To: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 23, 2009 at 2:46 PM, Peter P Waskiewicz Jr
<peter.p.waskiewicz.jr@intel.com> wrote:
> This patchset adds a new CPU mask for SMP systems to the irq_desc
> struct. =C2=A0It also exposes an API for underlying device drivers to
> assist irqbalance in making smarter decisions when balancing, especia=
lly
> in a NUMA environment. =C2=A0For example, an ethernet driver with MSI=
-X may
> wish to limit the CPUs that an interrupt can be balanced within to
> stay on a single NUMA node. =C2=A0Current irqbalance operation can mo=
ve the
> interrupt off the node, resulting in cross-node memory accesses and
> locks.
>
> The API is a get/set API within the kernel, along with a /proc entry
> for the interrupt.
>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com=
>
> ---

1) I think you should consider CONFIG_CPUMASK_OFFSTACK which will affec=
t
   node_affinity.
2) It seems like this patch can't work with SPARSE_IRQ.

Thanks,
Yong
