From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 5/6] net: orphan frags on receive
Date: Mon, 14 May 2012 22:18:43 +0300
Message-ID: <20120514191843.GA18235@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <a3353f6235d877c6b2d300eb5a914dbc9b78824d.1336397823.git.mst@redhat.com>
 <1336571692.25514.122.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755118Ab2ENTSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 15:18:44 -0400
Content-Disposition: inline
In-Reply-To: <1336571692.25514.122.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 09, 2012 at 02:54:52PM +0100, Ian Campbell wrote:
> On Mon, 2012-05-07 at 14:54 +0100, Michael S. Tsirkin wrote:
> > zero copy packets are normally sent to the outside
> > network, but bridging, tun etc might loop them
> > back to host networking stack. If this happens
> > destructors will never be called, so orphan
> > the frags immediately on receive.
> 
> I think this deceptively simply patch is actually the meat of the
> series.

Eric, does this patch look ok to you?
It's key to both my and ian's zerocopy work.

-- 
MST
