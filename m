From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] wimax: i2400m - prevent a possible kernel bug due
 to missing fw_name string
Date: Tue, 27 Mar 2012 22:30:25 -0400 (EDT)
Message-ID: <20120327.223025.169090768895030295.davem@davemloft.net>
References: <1332761036-8913-1-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, inaky.perez-gonzalez@intel.com
To: phil.sutter@viprinet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757250Ab2C1Cac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:30:32 -0400
In-Reply-To: <1332761036-8913-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil.sutter@viprinet.com>
Date: Mon, 26 Mar 2012 13:23:55 +0200

> This happened on a machine with a custom hotplug script calling nameif,
> probably due to slow firmware loading. At the time nameif uses ethtool
> to gather interface information, i2400m->fw_name is zero and so a null
> pointer dereference occurs from within i2400m_get_drvinfo().
> 
> Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>

Applied.
