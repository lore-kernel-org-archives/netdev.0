From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sfc: cleanup a condition in efx_udp_tunnel_del()
Date: Wed, 22 Mar 2017 19:25:34 -0700 (PDT)
Message-ID: <20170322.192534.1032558291775882753.davem@davemloft.net>
References: <20170322091002.GB14520@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46904 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753864AbdCWC0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:26:11 -0400
In-Reply-To: <20170322091002.GB14520@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 22 Mar 2017 12:10:02 +0300

> Presumably if there is an "add" function, there is also a "del"
> function.  But it causes a static checker warning because it looks like
> a common cut and paste bug.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Looks good, applied, thanks Dan.
