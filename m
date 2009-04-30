From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 00/16] MDIO and ethtool enhancements
Date: Thu, 30 Apr 2009 02:28:27 +0100
Message-ID: <1241054907.22157.24.camel@deadeye>
References: <1241028086.3246.30.camel@achroite>
	 <20090429.173128.241115147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33968 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751109AbZD3B2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 21:28:34 -0400
In-Reply-To: <20090429.173128.241115147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-29 at 17:31 -0700, David Miller wrote:
[...]
> > - Is it reasonable to carry on using the MII ioctl interface with flags?
> 
> I don't know, I'm a little disappointed it's still around but
> I suppose someone finds it useful.
[...]

It's definitely a useful debugging feature, though probably less
important where the PHY driver is implemented in firmware.  We also use
it for field upgrades of PHY firmware.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
