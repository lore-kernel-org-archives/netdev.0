From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: Advertize vxlan offload features when
 supported
Date: Wed, 18 Jun 2014 16:50:56 -0700 (PDT)
Message-ID: <20140618.165056.1727314662187072206.davem@davemloft.net>
References: <1403010669-19731-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756568AbaFRXu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 19:50:58 -0400
In-Reply-To: <1403010669-19731-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 17 Jun 2014 16:11:09 +0300

> When the underlying device supports TCP offloads for VXLAN/UDP
> encapulated traffic, we need to reflect that through the hw_enc_features
> field of the bonding net-device. This will cause the xmit path
> in the core networking stack to provide bonding with encapsulated
> GSO frames to offload into the HW etc.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thank you.
