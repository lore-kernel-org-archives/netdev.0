From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
 2014-11-14
Date: Sun, 16 Nov 2014 15:04:26 -0500 (EST)
Message-ID: <20141116.150426.1513510283700264522.davem@davemloft.net>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaKPUEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 15:04:30 -0500
In-Reply-To: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Nov 2014 22:08:23 -0800

> This series contains updates to i40e only.

Patch #3 needs to be updated to do error handling for the case where
skb_linearize() fails, as pointed out by Eric Dumazet.
