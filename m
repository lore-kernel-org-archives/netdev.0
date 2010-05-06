From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] netdev: octeon_mgmt: Free TX skbufs in a timely
 manner.
Date: Thu, 06 May 2010 00:19:01 -0700 (PDT)
Message-ID: <20100506.001901.242136151.davem@davemloft.net>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
	<1273100593-11043-5-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754765Ab0EFHSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:18:54 -0400
In-Reply-To: <1273100593-11043-5-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed,  5 May 2010 16:03:11 -0700

> We also reduce the high water mark to 1 so skbufs are not stranded for
> long periods of time.  Since we are cleaning after each packet, no
> need to do it in the transmit path.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Applied.
