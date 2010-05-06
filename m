From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] netdev: octeon_mgmt: Fix race condition freeing TX
 buffers.
Date: Thu, 06 May 2010 00:18:50 -0700 (PDT)
Message-ID: <20100506.001850.35041932.davem@davemloft.net>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
	<1273100593-11043-3-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752136Ab0EFHSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:18:43 -0400
In-Reply-To: <1273100593-11043-3-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed,  5 May 2010 16:03:09 -0700

> Under heavy load the TX cleanup tasklet and xmit threads would race
> and try to free too many buffers.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Applied.
