From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 0/5] more statistics updates
Date: Mon, 20 Jun 2011 13:35:06 -0700
Message-ID: <20110620203506.363818794@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40983 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231Ab1FTUpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 16:45:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix drivers that are using 64 bit statistics with unsafe access on 32 bit.
These are compile tested only, because the hardware to test it is not
easily available.

