From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] mlx4e: Do not attempt to offload VXLAN ports that
 are unrecognized
Date: Thu, 16 Jun 2016 14:25:27 -0700 (PDT)
Message-ID: <20160616.142527.2295798849101410902.davem@davemloft.net>
References: <20160615214105.14734.93787.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466AbcFPVZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 17:25:28 -0400
In-Reply-To: <20160615214105.14734.93787.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Wed, 15 Jun 2016 14:42:11 -0700

> The mlx4e driver does not support more than one port for VXLAN offload.  As
> such expecting the hardware to offload other ports is invalid since it
> appears the parsing logic is used to perform Tx checksum and segmentation
> offloads.  Use the vxlan_port number to determine in which cases we can
> apply the offload and in which cases we can not.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied.
