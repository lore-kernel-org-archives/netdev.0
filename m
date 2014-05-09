From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: make a generic sysfs option store
 and fix comments
Date: Fri, 09 May 2014 16:13:26 -0400 (EDT)
Message-ID: <20140509.161326.1808390476882515095.davem@davemloft.net>
References: <1399551834-31583-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756796AbaEIUN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:13:28 -0400
In-Reply-To: <1399551834-31583-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu,  8 May 2014 14:23:54 +0200

> Introduce a generic option store function for sysfs and remove the
> specific ones. The attribute name is used to match against the option
> which is to be set.
> Also adjust the "name" of tlb_dynamic_lb option to match the sysfs
> entry and fix the comments and comment style in bond_sysfs.c
> The comments which showed obvious behaviour (i.e. behaviour that's seen
> in the option's entry) are removed, the ones that explained important
> points about the setting function have been moved above the respective
> set function in bond_options.c
> 
> There's only 1 exception: num_unsol_na/num_grat_arp since it has 2 names
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: David S. Miller <davem@davemloft.net>
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Nice cleanup, applied to net-next, thanks.
