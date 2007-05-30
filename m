From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/7] sky2: dont set bogus bit in PHY register
Date: Wed, 30 May 2007 09:53:01 -0400
Message-ID: <465D81BD.5090505@garzik.org>
References: <20070524222242.555399884@linux-foundation.org> <20070524222538.375321658@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33818 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485AbXE3NxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 09:53:06 -0400
In-Reply-To: <20070524222538.375321658@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This code inherited from the sk98lin driver is incorrect on the Yukon2.
> The GPHY_CTRL register values are specific to the internal PHY of the chip
> and the values used were leftovers.
> Driver was setting bit 13 which is now the INT polarity for the PHY!
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-3


