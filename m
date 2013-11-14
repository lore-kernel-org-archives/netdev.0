From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: don't permit to use ARP monitoring in
 802.3ad mode
Date: Thu, 14 Nov 2013 02:29:41 -0500 (EST)
Message-ID: <20131114.022941.611560061215223767.davem@davemloft.net>
References: <1384267060-10851-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab3KNH3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:29:42 -0500
In-Reply-To: <1384267060-10851-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 12 Nov 2013 15:37:40 +0100

> Currently the ARP monitoring is not supported with 802.3ad, and it's
> prohibited to use it via the module params.
> 
> However we still can set it afterwards via sysfs, cause we only check for
> *LB modes there.
> 
> To fix this - add a check for 802.3ad mode in bonding_store_arp_interval.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied and queued up for -stable, thanks.
