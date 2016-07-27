From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v10 12/12] bpf: add sample for xdp forwarding and
 rewrite
Date: Wed, 27 Jul 2016 20:25:48 +0200
Message-ID: <20160727202548.0dbe4117@redhat.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
	<1468955817-10604-13-git-send-email-bblanco@plumgrid.com>
	<20160719220536.GH64618@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>, brouer@redhat.com,
	Rana Shahout <ranas@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbcG0S0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2016 14:26:00 -0400
In-Reply-To: <20160719220536.GH64618@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Jul 2016 15:05:37 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Tue, Jul 19, 2016 at 12:16:57PM -0700, Brenden Blanco wrote:
> > Add a sample that rewrites and forwards packets out on the same
> > interface. Observed single core forwarding performance of ~10Mpps.
> > 
> > Since the mlx4 driver under test recycles every single packet page, the
> > perf output shows almost exclusively just the ring management and bpf
> > program work. Slowdowns are likely occurring due to cache misses.  
> 
> long term we need to resurrect your prefetch patch. sux to leave
> so much performance on the table.

I will do some (more) attempts at getting prefetching working, also in
a way that benefit the normal stack (when I'm back from vacation, and
when net-next opens again).

I think Rana is also looking into this for the mlx5 driver (based on
some patches I send to her).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
