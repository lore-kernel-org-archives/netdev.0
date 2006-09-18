From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: tcp congestion policy selection link order fragile
Date: Mon, 18 Sep 2006 17:40:48 +0200
Message-ID: <20060918154048.GA18240@outpost.ds9a.nl>
References: <20060917122153.GA2932@outpost.ds9a.nl> <20060918.015130.34760190.davem@davemloft.net> <20060918095936.GA6161@outpost.ds9a.nl> <20060918.070600.107685035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:14731 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1751789AbWIRPku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 11:40:50 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060918.070600.107685035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2006 at 07:06:00AM -0700, David Miller wrote:

> Any ordering scheme is wrong or unexpected for _somebody_.  Look how

I agree violently. Would you agree that it would be best to have a mechanism
that explicitly sets a sane default, and does not rely on ordering?

My implementation indeed broke your intentions, but would you be open to
revamping things so the default policy is not dependent on load order?

What would the desired default be, 'BIC' in all cases?

Thanks. 

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
