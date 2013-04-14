From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: use htonl when snooping for loopback
 address
Date: Sun, 14 Apr 2013 15:43:48 -0400 (EDT)
Message-ID: <20130414.154348.2275229894750194737.davem@davemloft.net>
References: <1365931299-26240-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: mike.rapoport@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab3DNTnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 15:43:49 -0400
In-Reply-To: <1365931299-26240-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Sun, 14 Apr 2013 12:21:39 +0300

> Currently "bridge fdb show dev vxlan0" lists loopback address as
> "1.0.0.127". Using htonl(INADDR_LOOPBACK) rather than passing it
> directly to vxlan_snoop fixes the problem.
> 
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>

Applied.
