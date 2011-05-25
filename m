From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: make dev_disable_lro use physical device if
 passed a vlan dev (v2)
Date: Wed, 25 May 2011 17:56:22 -0400 (EDT)
Message-ID: <20110525.175622.1596224111875186302.davem@davemloft.net>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
	<1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
	<1306261869-7276-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812Ab1EYV5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 17:57:33 -0400
In-Reply-To: <1306261869-7276-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 24 May 2011 14:31:09 -0400

> If the device passed into dev_disable_lro is a vlan, then repoint the dev
> poniter so that we actually modify the underlying physical device.
> 
> Signed-of-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
