From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: fix kstrtou8() return value
 verification in num_peer_notif
Date: Mon, 06 Jan 2014 16:26:17 -0500 (EST)
Message-ID: <20140106.162617.688128238726144334.davem@davemloft.net>
References: <1389005680-9063-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756359AbaAFV0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:26:19 -0500
In-Reply-To: <1389005680-9063-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon,  6 Jan 2014 11:54:40 +0100

> It returns 0 in case of success, !0 error otherwise. Fix the improper error
> verification.
> 
> Fixes: 2c9839c143bbc ("bonding: add num_grat_arp attribute netlink support")
> CC: sfeldma@cumulusnetworks.com
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
