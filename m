From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: destroy proc directory only after
 all bonds are gone
Date: Thu, 17 Jul 2014 16:37:45 -0700 (PDT)
Message-ID: <20140717.163745.14681252611762551.davem@davemloft.net>
References: <1405591448-31797-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbaGQXhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 19:37:46 -0400
In-Reply-To: <1405591448-31797-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Thu, 17 Jul 2014 12:04:08 +0200

> Currently we might arrive to bond_net_exit() with some bonds left (that
> were created while the module is unloading). We take care of that by
> destroying sysfs (the last possibility to add new bonds) and then
> destroying all the remaining bonds.
> 
> However, we destroy the /proc/net/bonding directory before destroying those
> last bonds, and get a warning that we're trying to destroy a non-empty
> proc directory (containing /proc/net/bonding/bondX).
> 
> Fix this by moving bond_destroy_proc_dir() after all the bonds are
> destroyed, so that we're sure that no bonds exist.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

Applied, thanks.
