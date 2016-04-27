From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/1] pch_gbe: replace private tx ring lock with
 common netif_tx_lock
Date: Wed, 27 Apr 2016 23:28:48 +0200
Message-ID: <20160427212848.GA10269@electric-eye.fr.zoreil.com>
References: <20160426224921.GA29558@electric-eye.fr.zoreil.com>
 <57207E8A.8030004@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39890 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbcD0V2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 17:28:53 -0400
Content-Disposition: inline
In-Reply-To: <57207E8A.8030004@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@cumulusnetworks.com> :
> On 04/27/2016 12:49 AM, Francois Romieu wrote:
[...]
> > @@ -1652,7 +1652,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
> >  
> >  		netdev_dbg(adapter->netdev, "next_to_clean : %d\n",
> >  			   tx_ring->next_to_clean);
> > -		spin_unlock(&tx_ring->tx_lock);
> > +		netif_tx_lock(adapter->netdev);
> 
> Shouldn't this be netif_tx_unlock ?

It should. Thanks for reviewing.

-- 
Ueimor
