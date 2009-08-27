From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] sfc: Work around XMAC bug causing packet loss with
 some peers
Date: Wed, 26 Aug 2009 18:04:20 -0700 (PDT)
Message-ID: <20090826.180420.114585490.davem@davemloft.net>
References: <1251310679.27345.17.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53167
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754520AbZH0BEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 21:04:06 -0400
In-Reply-To: <1251310679.27345.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 26 Aug 2009 19:17:59 +0100

> Received frames must be re-clocked by the local XGXS to the 156.25 MHz
> (DDR) clock of the XGMII.  If the remote clock is slightly faster this
> can reduce a minimum IPG of 64 bit-times (1 cycle) to 32 bit-times
> (half a cycle).  If the XMAC detects that a frame has reached the
> maximum RX frame length in the same cycle that it receives one of
> these reduced IPGs, it may miss the IPG, causing two valid frames to
> be treated as a single invalid frame (over-length with bad CRC).
> 
> We work around this by increasing the maximum RX frame length so that
> peers with matched MTU will not provoke this bug.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
