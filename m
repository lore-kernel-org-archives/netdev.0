From: Patrick McHardy <kaber@trash.net>
Subject: Re: [nf-next PATCH] netfilter: Extend SYNPROXY with a --continue
 option
Date: Wed, 28 Aug 2013 18:00:42 +0200
Message-ID: <20130828160038.GA25799@macbook.localnet>
References: <20130828152549.8250.97982.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, as@one.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130828152549.8250.97982.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 28, 2013 at 05:26:55PM +0200, Jesper Dangaard Brouer wrote:
> Packets reaching SYNPROXY are default dropped, as they are most likely
> invalid (given the state matching).  In other configurations it might
> be beneficial to let packet not consumed by SYNPROXY (SYN and ACK) to
> continue being processed by the stack.
> 
> Introducing a --continue option/flag for the SYNPROXY target to allow
> these unmatched packets to continue being processed.  This would also
> help in debugging the module via LOG.

I don't think we should add an option for this. Just DROP packets consumed
by the target and have the other ones continue.
