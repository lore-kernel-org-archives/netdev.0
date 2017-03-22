From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: integer overflow bug in debugfs
Date: Tue, 21 Mar 2017 17:43:47 -0700 (PDT)
Message-ID: <20170321.174347.845428848919617726.davem@davemloft.net>
References: <20170317205234.GA2888@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rasesh.mody@cavium.com, kgudipat@brocade.com,
        sudarsana.kalluru@cavium.com, Dept-GELinuxNICDev@cavium.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933045AbdCVAoc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 20:44:32 -0400
In-Reply-To: <20170317205234.GA2888@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 17 Mar 2017 23:52:35 +0300

> We could allocate less memory than intended because we do:
> 
> 	bnad->regdata = kzalloc(len << 2, GFP_KERNEL);
> 
> The shift can overflow leading to a crash.  This is debugfs code so the
> impact is very small.
> 
> Fixes: 7afc5dbde091 ("bna: Add debugfs interface.")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
