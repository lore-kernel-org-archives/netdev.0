From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: disable rx checksum on Yukon XL
Date: Fri, 23 Nov 2007 22:10:10 -0500
Message-ID: <47479612.4090200@pobox.com>
References: <20071121145526.1f0b9f06@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44350 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754208AbXKXDKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:10:12 -0500
In-Reply-To: <20071121145526.1f0b9f06@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The Marvell Yukon XL chipset appears to have a hardware glitch
> where it will repeat the checksum of the last packet. Of course, this is
> timing sensitive and only happens sometimes...
> 
> More info: http://bugzilla.kernel.org/show_bug.cgi?id=9381
> 
> As a workaround just disable hardware checksumming by default on
> this chip version. The earlier workaround for PCIX, dual port
> was also on Yukon XL so don't need to disable checksumming there.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied #upstream-fixes


