From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: 3ad: allow to set ad_actor settings
 while the bond is up
Date: Thu, 11 Feb 2016 04:31:42 -0500 (EST)
Message-ID: <20160211.043142.1134359294601410129.davem@davemloft.net>
References: <1454604148-28658-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbcBKJbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 04:31:47 -0500
In-Reply-To: <1454604148-28658-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Thu,  4 Feb 2016 17:42:28 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> No need to require the bond down while changing these settings, the change
> will be reflected immediately and the 3ad mode will sort itself out.
> For faster convergence set port->ntt to true in order to generate new
> LACPDUs immediately.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
