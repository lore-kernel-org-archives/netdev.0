From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: permit enslaving interfaces without
 set_mac support
Date: Tue, 15 Jul 2014 22:55:02 -0700 (PDT)
Message-ID: <20140715.225502.1504304277971621146.davem@davemloft.net>
References: <1405423561-9114-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934451AbaGPFzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 01:55:03 -0400
In-Reply-To: <1405423561-9114-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Tue, 15 Jul 2014 13:26:01 +0200

> Currently we exit if the slave isn't the first slave, doesn't support mac
> address setting and fail_over_mac isn't FOM_ACTIVE. It's wrong because we
> only require ndo_set_mac_address in case bonding is in active-backup mode
> and FOM isn't FOM_ACTIVE.
> 
> To fix this - only exit with an error if we're in a/b mode and have
> fail_over_mac != FOM_ACTIVE.
> 
> Also, maintain current behaviour on the first slave (forcibly change fom to
> FOM_ACTIVE) to not break anyone's configuration.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

Applied, thank you.
