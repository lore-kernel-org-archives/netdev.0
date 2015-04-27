From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/bonding: Make DRV macros private
Date: Sun, 26 Apr 2015 23:00:21 -0400 (EDT)
Message-ID: <20150426.230021.471975772251803616.davem@davemloft.net>
References: <1430052957-7345-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	j.vosburgh@gmail.com, matanb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49602 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbbD0DAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 23:00:23 -0400
In-Reply-To: <1430052957-7345-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 26 Apr 2015 15:55:57 +0300

> From: Matan Barak <matanb@mellanox.com>
> 
> The bonding modules currently defines four macros with
> general names that pollute the global namespace:
> DRV_VERSION
> DRV_RELDATE
> DRV_NAME
> DRV_DESCRIPTION
> 
> Fixing that by defining a private bonding_priv.h
> header files which includes those defines.
> 
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
