From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: dev_map_alloc() shouldn't return NULL
Date: Mon, 24 Jul 2017 16:23:26 -0700 (PDT)
Message-ID: <20170724.162326.2235132369097751651.davem@davemloft.net>
References: <20170722074004.3abeucov67n3sbqs@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, john.fastabend@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752558AbdGXXX1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:23:27 -0400
In-Reply-To: <20170722074004.3abeucov67n3sbqs@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 22 Jul 2017 10:40:04 +0300

> We forgot to set the error code on two error paths which means that we
> return ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is
> not expecting that and will have a NULL dereference.
> 
> Fixes: 546ac1ffb70d ("bpf: add devmap, a map for storing net device references")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
