From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: What's new in wireless-dev?
Date: Wed, 12 Jul 2006 08:48:32 -0400
Message-ID: <20060712124827.GB4213@tuxdriver.com>
References: <20060711204553.GB26186@tuxdriver.com> <20060712114832.4f1dbac6@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:64786 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751360AbWGLMs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 08:48:59 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060712114832.4f1dbac6@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2006 at 11:48:32AM +0200, Jiri Benc wrote:
> On Tue, 11 Jul 2006 16:45:58 -0400, John W. Linville wrote:
> > John W. Linville:
> >       d80211: use netif_tx_lock API
> 
> > --- a/net/d80211/ieee80211.c
> > +++ b/net/d80211/ieee80211.c
> > @@ -1338,7 +1338,7 @@ static void ieee80211_tx_pending(unsigne
> >  	struct ieee80211_txrx_data tx;
> >  	int i, ret, reschedule = 0;
> >  
> > -	spin_lock_bh(&dev->xmit_lock);
> > +	netif_tx_lock_bh(dev);
> >  	dev->xmit_lock_owner = smp_processor_id();
> 
> Those dev->xmit_lock_owner assignments are done in netif_tx_[un]lock_bh,
> so they should go away as well.

Doh!  I missed that...thanks for the heads-up!

John
-- 
John W. Linville
linville@tuxdriver.com
