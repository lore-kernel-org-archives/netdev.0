From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 07/11] fs_enet: enable transmit time stamping.
Date: Wed, 22 Jun 2011 16:56:32 -0700
Message-ID: <20110622235632.GA31004@mcarlson.broadcom.com>
References: <cover.1308481491.git.richard.cochran@omicron.at>
 <2a8677b99c6b8d0e34bbf0f6d6a44e6c7992636d.1308481492.git.richard.cochran@omicron.at>
 <1308484684.3539.76.camel@edumazet-laptop>
 <20110619181212.GA3594@riccoc20.at.omicron.at>
 <1308508249.3539.78.camel@edumazet-laptop>
 <20110620065831.GA5771@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Richard Cochran" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3505 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758358Ab1FVXxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 19:53:06 -0400
In-Reply-To: <20110620065831.GA5771@riccoc20.at.omicron.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 19, 2011 at 11:58:31PM -0700, Richard Cochran wrote:
> On Sun, Jun 19, 2011 at 08:30:49PM +0200, Eric Dumazet wrote:
> > Le dimanche 19 juin 2011 ? 20:12 +0200, Richard Cochran a ?crit :
> > 
> > > Thanks for your review. I have posted a fix for the first batch (since
> > > they are already in next) and reposted this series.
> > > 
> > > But, considering your point, it looks like pxa168_eth and mv643xx_eth
> > > (see patches 9 and 10 of this series) already access skb->len unsafely.
> > > 
> > > Would you care to comment on those spots, too?
> > 
> > They certainly are buggy, at a first glance.
> > 
> > Not only skb->len is unsafe, but netif_tx_stop_queue() calls are unsafe
> > too.
> 
> Out of the MAC drivers in my two batches, only drivers/net/tg3.c calls
> netif_tx_stop_queue(txq);
> 
> However, I don't know how to fix that. Anyone else care to take a look?

How is netif_tx_stop_queue() unsafe?

