From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Pull request: SIOCGHWTSTAMP ioctl
Date: Fri, 6 Dec 2013 17:38:35 +0000
Message-ID: <1386351515.1516.156.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
	 <20131205.194624.1335606571649336470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	David Daney <david.daney@cavium.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Takahiro Shimizu <tshimizu818@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: David Miller <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29762 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073Ab3LFRik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:38:40 -0500
In-Reply-To: <20131205.194624.1335606571649336470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 19:46 -0500, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 5 Dec 2013 23:37:12 +0000
> 
> > 1. Add the SIOCGHWTSTAMP ioctl and update the timestamping
> > documentation.
> > 2. Implement SIOCGHWTSTAMP in most drivers that support SIOCSHWTSTAMP.
> > 3. Add a test program to exercise SIOC{G,S}HWTSTAMP.
> 
> Pulled, thanks Ben.

Thanks.  I hope all the drivers still work, as you didn't leave long for
review.

There are a few drivers I didn't touch because they don't appear to keep
a soft copy of the timestamp configuration:

drivers/net/ethernet/intel/igb/igb_main.c
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
drivers/net/ethernet/octeon/octeon_mgmt.c
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c

phylib and the dp83640 driver will also need to be updated to support
this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
