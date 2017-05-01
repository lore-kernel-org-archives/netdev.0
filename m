From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwtunnel: fix error path in
 lwtunnel_fill_encap()
Date: Sun, 30 Apr 2017 22:42:59 -0400 (EDT)
Message-ID: <20170430.224259.758720932636802809.davem@davemloft.net>
References: <20170428130347.53hagk77wh6scmcs@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bianpan2016@163.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, rshearma@brocade.com, tom@herbertland.com,
        david.lebrun@uclouvain.be, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165347AbdEACnB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:43:01 -0400
In-Reply-To: <20170428130347.53hagk77wh6scmcs@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 28 Apr 2017 16:03:48 +0300

> We recently added a check to see if nla_nest_start() fails.  There are
> two issues with that.  First, if it fails then I don't think we should
> call nla_nest_cancel().  Second, it's slightly convoluted but the
> current code returns success but we should return -EMSGSIZE instead.
> 
> Fixes: a50fe0ffd76f ("lwtunnel: check return value of nla_nest_start")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
