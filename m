From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix off-by-one error
Date: Thu, 01 Nov 2012 11:54:16 -0400 (EDT)
Message-ID: <20121101.115416.1679728403071754822.davem@davemloft.net>
References: <1351694571-26369-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964810Ab2KAPyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 11:54:20 -0400
In-Reply-To: <1351694571-26369-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 31 Oct 2012 15:42:51 +0100

> Fix off-by-one error because IFNAMSIZ == 16 and when this
> code gets executed we stick a NULL byte where we should not.
> 
> How to reproduce:
>  with CONFIG_CC_STACKPROTECTOR=y (otherwise it may pass by silently)
>  modprobe bonding; echo 1 > /sys/class/net/bond0/bonding/mode;
>  echo "AAAAAAAAAAAAAAAA" > /sys/class/net/bond0/bonding/primary;
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

I've applied both of your patches, thanks.
