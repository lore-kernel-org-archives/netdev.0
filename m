From: robert@herjulf.net
Subject: Re: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 4/5 for
 net-next-2.6
Date: Tue, 24 Nov 2009 19:12:38 +0100
Message-ID: <19212.8726.367568.937773@gargle.gargle.HOWL>
References: <19211.4849.284727.703717@gargle.gargle.HOWL>
	<1259017659.16503.138.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atthis.its.uu.se ([130.238.7.58]:34921 "EHLO atthis.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933350AbZKXQCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 11:02:38 -0500
In-Reply-To: <1259017659.16503.138.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Joe Perches writes:
 
 > Can you run ./scripts/checkpatch.pl on your patches please?

 Yes there were many objections... but my linux quantum is for over for now
 
 > > +	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_SLOPE, &pd->temp_slope)))
 > > +		goto out;
 > [etc...]
 > > +	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_OFFSET, &pd->tx_bias_offset)))
 > > +		goto out;
 > 
 > perhaps this is clearer as:
 > 
 > 	if (read_phy_diag(hw, 0x1, reg, loc) ||
 > 	    read_phy_diag(hw, 0x1, reg2, loc2) ||
 > 	...
 > 	    read_phy_diag(hw, 0x1, regN, locN))
 > 		goto out;

 Feel free to attack it...
 
 Cheers
					--ro
