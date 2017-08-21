From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: check type when freeing metadata dst
Date: Mon, 21 Aug 2017 10:57:57 -0700 (PDT)
Message-ID: <20170821.105757.389405605152815901.davem@davemloft.net>
References: <a983211c-530a-8f73-ed00-c95840ce3d08@cogentembedded.com>
        <20170818123135.518080-1-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        sridhar.samudrala@intel.com, horms@verge.net.au
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752667AbdHUR56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 13:57:58 -0400
In-Reply-To: <20170818123135.518080-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Fri, 18 Aug 2017 14:31:35 +0200

> Commit 3fcece12bc1b ("net: store port/representator id in metadata_dst")
> added a new type field to metadata_dst, but metadata_dst_free() wasn't
> updated to check it before freeing the METADATA_IP_TUNNEL specific dst
> cache entry.
> 
> This is not currently causing problems since it's far enough back in the
> struct to be zeroed for the only other type currently in existance
> (METADATA_HW_PORT_MUX), but nevertheless it's not correct.
> 
> Fixes: 3fcece12bc1b ("net: store port/representator id in metadata_dst")
> Signed-off-by: David Lamparter <equinox@diac24.net>

Applied.
