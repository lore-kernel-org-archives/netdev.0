From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/7] sky2: PHY page register fixes
Date: Wed, 30 May 2007 09:59:32 -0400
Message-ID: <465D8344.9050601@garzik.org>
References: <20070524222242.555399884@linux-foundation.org> <20070524222538.637936263@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33918 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbXE3N7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 09:59:33 -0400
In-Reply-To: <20070524222538.637936263@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Several of the PHY registers are multiplexed; access to
> register must be proceeded by setting page register.
> 
> The driver setup is safer if this is done before the access
> rather than depending on the last value.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

NAK for 2.622 - this appears to be a highly speculative cleanup-style 
change that is not an appropriate submission so late in the Release 
Candidate cycle.

I would have expected this sort of change to have been brewing for a 
little while in -mm, via netdev#upstream perhaps.  As it is, this change 
has been zero testing exposure, which is not something we want in a -rc2 
or -rc3.

	Jeff


