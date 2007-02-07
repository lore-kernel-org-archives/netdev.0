From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] skge: handle zero address at open
Date: Tue, 06 Feb 2007 19:08:30 -0500
Message-ID: <45C9187E.5030708@garzik.org>
References: <20070202162250.980620000@linux-foundation.org> <20070202162419.046994000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56518 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030251AbXBGAIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 19:08:32 -0500
In-Reply-To: <20070202162419.046994000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Some motherboards are broken and have no address set. Failing at probe time 
> prevents the device from ever being used (like to download a fixed BIOS). Instead
> warn on probe and check again when device is brought up. That way the address
> can be set.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-4


