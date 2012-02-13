From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: remove assignment of random mac on
 enic vf
Date: Mon, 13 Feb 2012 00:51:19 -0500 (EST)
Message-ID: <20120213.005119.487737759192819670.davem@davemloft.net>
References: <20120212081243.7875.56830.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652Ab2BMFvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 00:51:23 -0500
In-Reply-To: <20120212081243.7875.56830.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Sun, 12 Feb 2012 00:12:44 -0800

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> This patch removes random mac assignment on vf's. The vf's will start with
> a zero mac and with upcoming support in fw/driver, a vf mac can be set
> via the pf. vf's also support ndo_set_mac_address. This decision was made
> based on the fact that a random mac on a vf is not really needed. And this
> will reduce some of the problems with the vf's getting a new mac on
> every driver load/unload (one of them being udev renaming the device on ever
> load/unload and reboot).
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: sujith sankar <ssujith@cisco.com>
> Signed-off-by: ChingWei Chang <cwchang@cisco.com>

Applied.
