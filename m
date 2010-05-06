From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] netdev: octeon_mgmt: Fix race manipulating irq
 bits.
Date: Thu, 06 May 2010 00:18:55 -0700 (PDT)
Message-ID: <20100506.001855.15241347.davem@davemloft.net>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
	<1273100593-11043-4-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754731Ab0EFHSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:18:48 -0400
In-Reply-To: <1273100593-11043-4-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed,  5 May 2010 16:03:10 -0700

> Don't re-read the interrupt status register, clear the exact bits we
> will be testing.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Applied.
