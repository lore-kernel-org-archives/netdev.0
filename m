From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net 3/6] pch_gbe: Validate hwtstamp_config completely
 before applying it
Date: Thu, 14 Nov 2013 08:27:45 +0100
Message-ID: <20131114072743.GB4908@netboy>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
 <1384389770.29151.9.camel@bwh-desktop.uk.level5networks.com>
 <20131114072011.GA4908@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:47652 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab3KNH1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:27:55 -0500
Received: by mail-we0-f178.google.com with SMTP id u57so982810wes.37
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 23:27:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131114072011.GA4908@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 08:21:37AM +0100, Richard Cochran wrote:
> On Thu, Nov 14, 2013 at 12:42:50AM +0000, Ben Hutchings wrote:
> >  
> > +	adapter->hwts_tx_en = cfg.tx_type == HWTSTAMP_TX_ON;
> > +
> 
> But now there is no way to turn transmit time stamping off?

Sorry, overlooked that '==' operator. Tricky.

Thanks,
Richard
