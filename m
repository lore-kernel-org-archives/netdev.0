From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix a return in sockmap_get_from_fd()
Date: Fri, 18 Aug 2017 10:18:35 -0700 (PDT)
Message-ID: <20170818.101835.574448732763821120.davem@davemloft.net>
References: <20170818071210.wyq37kura6wz6bx6@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, john.fastabend@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751446AbdHRRSg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:18:36 -0400
In-Reply-To: <20170818071210.wyq37kura6wz6bx6@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 18 Aug 2017 10:27:02 +0300

> "map" is a valid pointer.  We wanted to return "err" instead.  Also
> let's return a zero literal at the end.
> 
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
