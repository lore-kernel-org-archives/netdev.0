From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 17:06:12 +0400
Message-ID: <20070927130610.GB8897@2ka.mipt.ru>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au> <20070927100753.GA22323@2ka.mipt.ru> <20070927102916.GA15749@gondor.apana.org.au> <20070927124120.GA8897@2ka.mipt.ru> <1190897523.4290.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39432 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753425AbXI0NHC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 09:07:02 -0400
Content-Disposition: inline
In-Reply-To: <1190897523.4290.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 08:52:03AM -0400, jamal (hadi@cyberus.ca) wrote:
> On Thu, 2007-27-09 at 16:41 +0400, Evgeniy Polyakov wrote:
> 
> > I've attached simple patch which moves checksum helpers out of
> > CONFIG_NETFILTER option but still in the same linux/netfilter.h header.
> > This should be enough for removing 'select NETFILTER' in your patch.
> 
> Is there any point in keeping the code inside netfilter or keeping
> the nf_ prefix? something in net/utilities/ or net/core maybe?
> the nf_* can still exist in netfilter as aliases to wherever this is
> moved to.

No, there is no point in keeping that, I just wanted the smallest
possible change :)

-- 
	Evgeniy Polyakov
