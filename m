From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] sfc: a couple off by one bugs
Date: Wed, 01 Feb 2017 12:44:33 -0500 (EST)
Message-ID: <20170201.124433.584968147490170553.davem@davemloft.net>
References: <20170201085040.GA31514@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753706AbdBARok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:44:40 -0500
In-Reply-To: <20170201085040.GA31514@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 1 Feb 2017 11:50:40 +0300

> These checks are off by one.  These are just sanity checks and we don't
> ever pass invalid values for "encap_type" so it's harmless.
> 
> Fixes: 9b4108012517 ("sfc: insert catch-all filters for encapsulated traffic")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Please respin against net-next and Colin's fix.

Thanks.
