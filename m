From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: fix bond_option_mode_set warning
Date: Tue, 15 Jul 2014 22:56:13 -0700 (PDT)
Message-ID: <20140715.225613.1285857218662290489.davem@davemloft.net>
References: <1405433337-8806-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934442AbaGPF4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 01:56:14 -0400
In-Reply-To: <1405433337-8806-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue, 15 Jul 2014 16:08:57 +0200

> During the conversion to "static" functions this one got left out, only its
> prototype was converted, thus resulting in:
> drivers/net/bonding//bond_options.c:674:5: warning: symbol
> 'bond_option_mode_set' was not declared. Should it be static?
> 
> Fix it by making it static and also break the line in two as it was too
> long.
> 
> CC: Stephen Hemminger <stephen@networkplumber.org>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: David S. Miller <davem@davemloft.net>
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied, thanks Nikolay.
