From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] bonding: convert pr_* to netdev_*
Date: Tue, 15 Jul 2014 23:17:31 -0700 (PDT)
Message-ID: <20140715.231731.540227221117070349.davem@davemloft.net>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbaGPGRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 02:17:33 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Tue, 15 Jul 2014 19:35:57 +0200

> Currently bonding uses pr_info/warn/etc. function to print something, while
> it's encouraged to use netdev_info/warn/etc. in net/.
> 
> This patchset converts them where possible (i.e. where we have a working
> net_device). Also, convert pr_ratelimit* to net_() and remove the pr_fmt,
> to unify netdev_* and pr_* outputs.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

This looks fine to me, series applied, thanks.
