From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Mon, 29 Aug 2016 10:30:47 +0200
Message-ID: <20160829103047.3968a4d8@redhat.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
        <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, John Fastabend <john.fastabend@gmail.com>,
        bblanco@plumgrid.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39102 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756577AbcH2Iaw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 04:30:52 -0400
In-Reply-To: <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 28 Aug 2016 08:23:26 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 16-08-27 03:11 AM, John Fastabend wrote:
> > From: Alexei Starovoitov <ast@fb.com>
> >
> > This patch adds initial support for XDP on e1000 driver. Note e1000
> > driver does not support page recycling in general which could be
> > added as a further improvement. However for XDP_DROP and XDP_XMIT
> > the xdp code paths will recycle pages.
> >
> > This patch includes the rcu_read_lock/rcu_read_unlock pair noted by
> > Brenden Blanco in another pending patch.
> >
> >   net/mlx4_en: protect ring->xdp_prog with rcu_read_lock  
> 
> Do you have any perf numbers of drops of this vs tc drop at ingress?

Hi Jamal,

Can you please provide a simple "tc" command that implements "tc drop"?

Then, I'll add this to the series of tests I'm using for (what I call)
"zoom-in" benchmarking.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
