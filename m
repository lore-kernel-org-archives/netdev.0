From: Constantin Baranov <baranov@mercdev.com>
Subject: Re: [PATCH 2/2] niu: improve ethtool support for gigabit copper
 cards
Date: Tue, 17 Feb 2009 18:43:49 +0400
Message-ID: <20090217184349.3c735c58.baranov@mercdev.com>
References: <20090217154334.97837477.baranov@mercdev.com>
	<1234878837.3183.4.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.dewahost.net ([205.234.111.6]:48913 "EHLO
	titan.dewahost.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbZBQOn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 09:43:57 -0500
In-Reply-To: <1234878837.3183.4.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:
> On Tue, 2009-02-17 at 15:43 +0400, Constantin Baranov wrote:
> > Introduced support for link speed and duplex setting (ethtool -s),
> > link advertising parameters and autonegotiation (ethtool -r):
> [...]
> 
> I haven't looked closely at this, but is there anything here that can't
> be handled by mii_get_settings() and other functions in the mii driver?

mii_ethtool_gset() reports fixed set of supported modes and mii_ethtool_sset()
doesn't check whether requested mode is supported when autonegotiation is
disabled. Also mii module declares mdio_write() operation as returning void,
thus mii routines will ignore errors that may occur. Although all of these is
not so critical I decided not to use mii module.

-- 
Constantin Baranov,
Mercury Development, LLC
