From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net PATCH] 8139cp: Add dma_mapping_error checking
Date: Mon, 22 Jul 2013 23:48:39 +0200
Message-ID: <20130722214839.GB4997@electric-eye.fr.zoreil.com>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [92.243.8.30] ([92.243.8.30]:48155 "EHLO violet.fr.zoreil.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932388Ab3GVVsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 17:48:51 -0400
Content-Disposition: inline
In-Reply-To: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> :
[...]
> failed.  Untested as I have no hardware and the reporter has wandered off, but
> seems pretty straightforward.

It does not update dev->stats.tx_dropped in the xmit path.

-- 
Ueimor
