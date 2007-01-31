From: Chris Lightfoot <chris@ex-parrot.com>
Subject: Re: sky2 problems on Intel Mac Mini
Date: Wed, 31 Jan 2007 16:48:58 +0000
Message-ID: <HhJibFLstJjQ.SVY/DqXo8D+5tR9W9L+sbw@sphinx.mythic-beasts.com>
References: <DJgDe2E/Cvnb.CrmE6+LDxkzqNQTYvzH+WQ@sphinx.mythic-beasts.com> <20070130111520.47e07a79@freekitty> <9vX5bgSdy97f.I2iK+nv0AUYsJOXCRbPMsQ@sphinx.mythic-beasts.com> <iUr0b79BEZdD.1otwEM+70thgeGTyfwhw1g@sphinx.mythic-beasts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wumpus2.mythic-beasts.com ([212.69.38.51]:48214 "EHLO
	wumpus2.mythic-beasts.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030283AbXAaQtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 11:49:03 -0500
Content-Disposition: inline
In-Reply-To: <iUr0b79BEZdD.1otwEM+70thgeGTyfwhw1g@sphinx.mythic-beasts.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 09:15:22AM +0000, Chris Lightfoot wrote:
> On Wed, Jan 31, 2007 at 12:09:37AM +0000, Chris Lightfoot wrote:
> > On Tue, Jan 30, 2007 at 11:15:20AM -0800, Stephen Hemminger wrote:
> > > a) hardware flow control problems
> > >    look at ethtool -S eth0 statistics, are there flow control packets
> > >    showing up?
> 
> and immediately after a transmitter lockup this morning,
>     tx_mac_pause: 1
>     rx_mac_pause: 10601
> (I've attached a full dump of the stats and registers in
> case it's of use).

but after a crash this afternoon,

     tx_mac_pause: 0
     rx_mac_pause: 916

-- 
``[You] couldn't get a ticket for love nor money....
  Although, actually, I can't be sure of this
  since I only really offered money.'' (Daniel Davies)
