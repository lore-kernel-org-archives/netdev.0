From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: fix wrong port enabling in 802.3ad
Date: Wed, 19 Oct 2011 03:53:43 -0400 (EDT)
Message-ID: <20111019.035343.1749126014967505732.davem@davemloft.net>
References: <1318526483-16073-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994Ab1JSHyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 03:54:09 -0400
In-Reply-To: <1318526483-16073-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Thu, 13 Oct 2011 14:21:23 -0300

> The port shouldn't be enabled unless its current MUX
> state is DISTRIBUTING which is correctly handled by
> ad_mux_machine(), otherwise the packet sent can be
> lost because the other end may not be ready.
> 
> The issue happens on every port initialization, but
> as the ports are expected to move quickly to DISTRIBUTING,
> it doesn't cause much problem.  However, it does cause
> constant packet loss if the other peer has the port
> configured to stay in STANDBY (i.e. SYNC set to OFF).
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied, thanks.
