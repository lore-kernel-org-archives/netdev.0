From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: Add Queue mapping mode to af_packet fanout
 operation
Date: Wed, 22 Jan 2014 17:37:53 -0800 (PST)
Message-ID: <20140122.173753.552408633650405565.davem@davemloft.net>
References: <1390424504-18543-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbaAWBhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:37:55 -0500
In-Reply-To: <1390424504-18543-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 22 Jan 2014 16:01:44 -0500

> This patch adds a queue mapping mode to the fanout operation of af_packet
> sockets.  This allows user space af_packet users to better filter on flows
> ingressing and egressing via a specific hardware queue, and avoids the potential
> packet reordering that can occur when FANOUT_CPU is being used and irq affinity
> varies.
> 
> Tested successfully by myself.  applies to net-next
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

This looks fine, applied, thanks.
