From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix out of range parameters for
 bond_intmax_tbl
Date: Thu, 15 May 2014 23:37:14 -0400 (EDT)
Message-ID: <20140515.233714.289856779016047091.davem@davemloft.net>
References: <1400153723-8031-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbaEPDhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:37:16 -0400
In-Reply-To: <1400153723-8031-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 15 May 2014 13:35:23 +0200

> I've missed to add a NULL entry to the bond_intmax_tbl when I introduced
> it with the conversion of arp_interval so add it now.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> 
> Fixes: 7bdb04ed0dbf ("bonding: convert arp_interval to use the new option API")
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied and queued up for -stable, thanks.
