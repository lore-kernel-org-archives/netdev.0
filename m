From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Tue, 14 Apr 2015 08:36:15 -0700
Message-ID: <20150414153613.GA2781@Alexeis-MBP.westell.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <20150410132205.GF23070@casper.infradead.org>
 <20150410200901.GB5968@salvia>
 <20150412.211421.1771298417488412635.davem@davemloft.net>
 <20150413201913.GD20275@acer.localdomain>
 <552D07C4.1020509@mojatatu.com>
 <552D2E52.8020303@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, pablo@netfilter.org,
	tgraf@suug.ch, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552D2E52.8020303@intel.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 14, 2015 at 08:12:18AM -0700, John Fastabend wrote:
>
> I was hoping to push the skb lists onto something like rte_ring
> used by the DPDK folks or possibly some of the lockless ring work Jesper
> created. This is needed for many qdisc's to drop the qlock but not the
> ingress qdisc. Been busy working on switch bits lately but might be
> able to pick this up next merge window.

I've spent quite a bit of time reanalyzying your work ;) It seems
only trivial stuff left to drop ingress spinlock. Can you send me
your TC test scripts ? I'm only starting building mine and they're
not covering everything. Roughly I'm creating namespaces and running
traffic between them while varying csum/gso/gro offload settings.

