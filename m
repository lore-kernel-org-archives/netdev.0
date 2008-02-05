From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: fix for Yukon FE (regression in 2.6.25)
Date: Tue, 05 Feb 2008 13:32:44 -0500
Message-ID: <47A8ABCC.8060307@pobox.com>
References: <20080202105243.GA14581@vana.vc.cvut.cz>	<20080202120203.5387d1cb@extreme>	<47A51168.5040301@vandrovec.name> <20080204194513.700f6387@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Petr Vandrovec <petr@vandrovec.name>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42439 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbYBEScu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 13:32:50 -0500
In-Reply-To: <20080204194513.700f6387@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> The Yukon FE chip has a ram buffer therefore it needs the alignment
> restriction and hang check workarounds. 
> 
> Therefore:
>   * Autodetect the prescence/absence of ram buffer
>   * Rename the flag value to reflect this
>   * Use it consistently (ie don't reread register)
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied


