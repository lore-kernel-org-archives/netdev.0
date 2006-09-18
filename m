From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: tcp congestion policy selection link order fragile
Date: Mon, 18 Sep 2006 21:52:24 +0200
Message-ID: <20060918195224.GA26585@outpost.ds9a.nl>
References: <20060918095936.GA6161@outpost.ds9a.nl> <20060918.070600.107685035.davem@davemloft.net> <20060918154048.GA18240@outpost.ds9a.nl> <20060918.115309.88343320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:9625 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1751892AbWIRTwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 15:52:25 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060918.115309.88343320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2006 at 11:53:09AM -0700, David Miller wrote:
> > What would the desired default be, 'BIC' in all cases?
> 
> And if BIC is not enabled in the configuration, then what?

As the source notes "/* we'll always have reno */ ". This would make the
policy: the default is "bic" if available, otherwise it is "reno", which is
*always* available.

But it is all up to you. I'm willing to do the leg work.

	Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
