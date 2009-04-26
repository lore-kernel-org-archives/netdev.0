From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: tx timeout fix
Date: Sat, 25 Apr 2009 18:16:51 -0700 (PDT)
Message-ID: <20090425.181651.83669581.davem@davemloft.net>
References: <49F361E4.4050605@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751825AbZDZBQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 21:16:58 -0400
In-Reply-To: <49F361E4.4050605@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Sat, 25 Apr 2009 15:17:56 -0400

> This patch fixes the tx_timeout() to properly handle the clean up of
> the tx ring. It also sets the tx put pointer back to the correct
> position to be in sync with HW.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

You don't need to CC: Jeff Garzik as he is no longer handling
network driver patches.
