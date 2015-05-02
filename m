From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Sat, 2 May 2015 11:54:43 +0200
Message-ID: <20150502115443.2f89736e@redhat.com>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
	<20150502104621.4fede885@redhat.com>
	<55449C8D.4020902@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751112AbbEBJzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 05:55:16 -0400
In-Reply-To: <55449C8D.4020902@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 02 May 2015 11:44:45 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Hi Jesper,
> 
> On 05/02/2015 10:46 AM, Jesper Dangaard Brouer wrote:
> ...
> > First of all I love the idea of modifying pktgen to performance test
> > the RX path.
> >
> > I'm not sure the simple "rx" flag is a good "name".  It likely
> > conflicts with other work where pktgen can receive it own packets, e.g.
> > https://people.kth.se/~danieltt/pktgen/ or Ben Greer's solution.
> 
> Why do we start caring about out of tree code now? We never have,
> really. If there is no interest in merging this stuff upstream,
> then it's always the case that _their code_ needs to adapt iff you
> want to run on a more recent kernel; the kernel dictates the uapi,
> not some out of tree module. ;)

Sure, out-of-tree code should not control our choices.

I personally just don't like the "RX" flag name.
What about "STACK_RX" or "RX_INJECT"?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
