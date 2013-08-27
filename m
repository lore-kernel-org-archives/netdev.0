From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/5] netfilter: SYNPROXY target v3
Date: Tue, 27 Aug 2013 14:08:46 +0200
Message-ID: <20130827140846.1df57a2d@redhat.com>
References: <1377586216-7024-1-git-send-email-kaber@trash.net>
	<Pine.LNX.4.64.1308270951520.25216@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, as@one.com
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1308270951520.25216@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 27 Aug 2013 10:35:56 +0200 (CEST) Jesper Dangaard Brouer <hawk@diku.dk> wrote:
> On Tue, 27 Aug 2013, Patrick McHardy wrote:

> > We did some extensive testing on Monday and it verified all retransmit
> > bugs have been fixed. With 1.4Mpps SYNs the load on a 16 way Xeon L6530
> > 2.13 Ghz machine was between 3% and 6%.
> 
> It was a Xeon L5630 ;-)
> 
> We tested both SYN and ACK flood-attacks, while running ab (Apache 
> Benchmark). The 1.4Mpps comes from limitations on the generator host 
> (which used trafgen).  We also did some short tests with a modified 
> pktgen.  And Martin wrote a test tool, that would delay conn 
> establishment, to test retransmits.  And Patritck tested in (simulated) 
> drop situations.
> 
[...]
> >
> > From my POV, these patches are ready for merging now.
> 
> Yes, Martin and Patrick (and I) have done some good testing of the module. 
> And we have flushed out and solved several bugs in this process.

Series:

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
