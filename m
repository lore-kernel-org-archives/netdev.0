From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [patch v2 net-next] sfc: fix an off by one bug
Date: Tue, 7 Feb 2017 08:43:06 +0000
Message-ID: <bac041b8-d30f-cd06-359d-6347765d9879@solarflare.com>
References: <20170207074431.GA18377@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:17084 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753752AbdBGInP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 03:43:15 -0500
In-Reply-To: <20170207074431.GA18377@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/17 07:44, Dan Carpenter wrote:
> This bug is harmless because it's just a sanity check and we always
> pass valid values for "encap_type" but the test is off by one.
> 
> Fixes: 9b4108012517 ("sfc: insert catch-all filters for encapsulated traffic")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks Dan.

Acked-by: Bert Kenward <bkenward@solarflare.com>
