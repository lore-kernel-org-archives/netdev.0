From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/act_pedit: fix an error code
Date: Wed, 14 Jun 2017 15:31:17 -0400 (EDT)
Message-ID: <20170614.153117.2206133089943602575.davem@davemloft.net>
References: <20170614102930.GH29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, amir@vadai.me, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752004AbdFNTbT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:31:19 -0400
In-Reply-To: <20170614102930.GH29394@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 14 Jun 2017 13:29:31 +0300

> I'm reviewing static checker warnings where we do ERR_PTR(0), which is
> the same as NULL.  I'm pretty sure we intended to return ERR_PTR(-EINVAL)
> here.  Sometimes these bugs lead to a NULL dereference but I don't
> immediately see that problem here.
> 
> Fixes: 71d0ed7079df ("net/act_pedit: Support using offset relative to the conventional network headers")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
