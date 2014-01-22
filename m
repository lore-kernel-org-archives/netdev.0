From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Fix be_vlan_add/rem_vid() routines
Date: Tue, 21 Jan 2014 23:13:38 -0800 (PST)
Message-ID: <20140121.231338.75232999189290870.davem@davemloft.net>
References: <e4c76822-2f55-4a40-a0fa-c4cacb2a480f@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kalesh.purayil@emulex.com
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbaAVHNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:13:38 -0500
In-Reply-To: <e4c76822-2f55-4a40-a0fa-c4cacb2a480f@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Tue, 21 Jan 2014 15:50:55 +0530

> The current logic to put interface into VLAN Promiscous mode is not correct.
> We should increment "adapter->vlans_added" before calling be_vid_config().
> Also removed some unwanted log messages.
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
