From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [nf-next PATCH] netfilter: Extend SYNPROXY with a --continue
 option
Date: Thu, 29 Aug 2013 10:23:58 +0200
Message-ID: <20130829102358.4f93ee24@redhat.com>
References: <20130828152549.8250.97982.stgit@dragon>
	<20130828160038.GA25799@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130828160038.GA25799@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Aug 2013 18:00:42 +0200
Patrick McHardy <kaber@trash.net> wrote:

> On Wed, Aug 28, 2013 at 05:26:55PM +0200, Jesper Dangaard Brouer wrote:
> > Packets reaching SYNPROXY are default dropped, as they are most likely
> > invalid (given the state matching).  In other configurations it might
> > be beneficial to let packet not consumed by SYNPROXY (SYN and ACK) to
> > continue being processed by the stack.
> > 
> > Introducing a --continue option/flag for the SYNPROXY target to allow
> > these unmatched packets to continue being processed.  This would also
> > help in debugging the module via LOG.
> 
> I don't think we should add an option for this. Just DROP packets consumed
> by the target and have the other ones continue.

I agree.  I'll send a new patch, defaulting to XT_CONTINUE.

Self:
Nacked-by: Jesper Dangaard Brouer <brouer@redhat.com>
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
