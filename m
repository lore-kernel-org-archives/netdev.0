From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: remove sysfs before removing devices
Date: Fri, 05 Apr 2013 00:50:15 -0400 (EDT)
Message-ID: <20130405.005015.1039997502651377576.davem@davemloft.net>
References: <1365003993-13181-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab3DEEuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 00:50:16 -0400
In-Reply-To: <1365003993-13181-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Wed,  3 Apr 2013 17:46:33 +0200

> We have a race condition if we try to rmmod bonding and simultaneously add
> a bond master through sysfs. In bonding_exit() we first remove the devices
> (through rtnl_link_unregister() ) and only after that we remove the sysfs.
> If we manage to add a device through sysfs after that the devices were
> removed - we'll end up with that device/sysfs structure and with the module
> unloaded.
> 
> Fix this by first removing the sysfs and only after that calling
> rtnl_link_unregister().
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied and queued up for -stable, thanks!
