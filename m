From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: add support for busy polling to sctp protocol
Date: Sun, 20 Apr 2014 18:20:51 -0400 (EDT)
Message-ID: <20140420.182051.274562297709657182.davem@davemloft.net>
References: <1397762811-2989-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	dborkman@redhat.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbaDTWUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 18:20:52 -0400
In-Reply-To: <1397762811-2989-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 17 Apr 2014 15:26:51 -0400

> The busy polling socket option adds support for sockets to busy wait on data
> arriving on the napi queue from which they have most recently received a frame.
> Currently only tcp and udp support this feature, but theres no reason sctp can't
> do so as well.  Add it in so appliations can take advantage of it
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
