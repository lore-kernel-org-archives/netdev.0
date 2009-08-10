From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvlan: add tap device backend
Date: Mon, 10 Aug 2009 16:42:29 +0300
Message-ID: <20090810134229.GA10036@redhat.com>
References: <1249595428-21594-1-git-send-email-arnd@arndb.de> <200908092042.24686.arnd@arndb.de> <20090810085003.GA3654@redhat.com> <200908101529.46285.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37647 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754451AbZHJNox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2009 09:44:53 -0400
Content-Disposition: inline
In-Reply-To: <200908101529.46285.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2009 at 03:29:46PM +0200, Arnd Bergmann wrote:
> On Monday 10 August 2009, Michael S. Tsirkin wrote:
> > 
> > > Would it be enough to check the dev_queue_xmit() return
> > > code for NETDEV_TX_BUSY?
> > > 
> > > How would I get notified when it gets free again?
> > 
> > You can do this by creating a socket. Look at how tun does
> > this now.
> 
> Hmm, I was hoping to be able to avoid this, because I can
> interact more directly with the outbound physical interface
> using dev_queue_xmit() instead of netif_rx_ni().

Yea, that's what tun does. socket just notifies you when
packets are freed.

> I'll have a look. Thanks,
> 
> 	Arnd <><
