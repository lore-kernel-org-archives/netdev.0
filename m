From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] drivers/net: Call netif_carrier_off at the end of the probe
Date: Tue, 15 Feb 2011 16:22:46 +0100
Message-ID: <20110215152246.GA11719@electric-eye.fr.zoreil.com>
References: <1297771719-14202-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, aabdulla@nvidia.com,
	Ben Hutchings <ben@decadent.org.uk>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41126 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab1BOP0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 10:26:15 -0500
Content-Disposition: inline
In-Reply-To: <1297771719-14202-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
> Without calling of netif_carrier_off at the end of the probe the operstate
> is unknown when the device is initially opened. By default the carrier is
> on so when the device is opened and netif_carrier_on is called the link
> watch event is not fired and operstate remains zero (unknown).

Stated this way it sounds like a core dev layer issue.

I am not completely sure after reading some history. Namely:
- (37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71 ?)
- c276e098d3ee33059b4a1c747354226cec58487c 
- 22604c866889c4b2e12b73cbf1683bda1b72a313
- b47300168e770b60ab96c8924854c3b0eb4260eb

I am confused.

-- 
Ueimor
