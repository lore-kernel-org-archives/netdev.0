From: David Miller <davem@davemloft.net>
Subject: Re: bridge: faster compare for link local addresses
Date: Mon, 12 Mar 2007 16:26:09 -0700 (PDT)
Message-ID: <20070312.162609.74748115.davem@davemloft.net>
References: <20070312162015.5d22cd68@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752285AbXCLX0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 19:26:11 -0400
In-Reply-To: <20070312162015.5d22cd68@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Mar 2007 16:20:15 -0700

> Use logic operations rather than memcmp() to compare destination
> address with link local multicast addresses.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

With all of these Eric Dumazet'esque style changes I think we
may be producing a clone here :-)

Applied to net-2.6.22, thanks Stephen!
