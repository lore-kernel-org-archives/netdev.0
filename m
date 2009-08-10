From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] macvlan: add tap device backend
Date: Mon, 10 Aug 2009 15:29:46 +0200
Message-ID: <200908101529.46285.arnd@arndb.de>
References: <1249595428-21594-1-git-send-email-arnd@arndb.de> <200908092042.24686.arnd@arndb.de> <20090810085003.GA3654@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754524AbZHJNaE@vger.kernel.org>
In-Reply-To: <20090810085003.GA3654@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 August 2009, Michael S. Tsirkin wrote:
> 
> > Would it be enough to check the dev_queue_xmit() return
> > code for NETDEV_TX_BUSY?
> > 
> > How would I get notified when it gets free again?
> 
> You can do this by creating a socket. Look at how tun does
> this now.

Hmm, I was hoping to be able to avoid this, because I can
interact more directly with the outbound physical interface
using dev_queue_xmit() instead of netif_rx_ni().

I'll have a look. Thanks,

	Arnd <><
