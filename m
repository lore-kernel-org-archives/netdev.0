From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vlan: Propagate MAC address to VLANs unless
 explicitly set
Date: Tue, 03 May 2016 12:36:20 -0400 (EDT)
Message-ID: <20160503.123620.880041354137241272.davem@davemloft.net>
References: <5728BA0B.6050807@brocade.com>
	<5728C1AC.3090708@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933338AbcECQgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 12:36:47 -0400
In-Reply-To: <5728C1AC.3090708@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is, at the very least, a two byte hole in the vlan_dev_priv structure.
Put the boolean there as I asked you to.
