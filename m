From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [nf-next PATCH] netfilter: SYNPROXY let unrelated packets
 continue
Date: Wed, 4 Sep 2013 14:56:26 +0200
Message-ID: <20130904125626.GA4520@localhost>
References: <20130829101625.14346.41071.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130829101625.14346.41071.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 29, 2013 at 12:18:46PM +0200, Jesper Dangaard Brouer wrote:
> Packets reaching SYNPROXY were default dropped, as they were most
> likely invalid (given the recommended state matching).  This
> patch, changes SYNPROXY target to let packets, not consumed,
> continue being processed by the stack.
> 
> This will be more in line other target modules. As it will allow
> more flexible configurations of handling, logging or matching on
> packets in INVALID states.

Applied, thanks.
