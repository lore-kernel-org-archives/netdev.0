From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipv6: pointer math error in ip6_tnl_parse_tlv_enc_lim()
Date: Wed, 01 Feb 2017 12:31:02 -0500 (EST)
Message-ID: <20170201.123102.237978601616140108.davem@davemloft.net>
References: <20170201084632.GA29912@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753186AbdBARbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:31:05 -0500
In-Reply-To: <20170201084632.GA29912@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 1 Feb 2017 11:46:32 +0300

> Casting is a high precedence operation but "off" and "i" are in terms of
> bytes so we need to have some parenthesis here.
> 
> Fixes: fbfa743a9d2a ("ipv6: fix ip6_tnl_parse_tlv_enc_lim()")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
