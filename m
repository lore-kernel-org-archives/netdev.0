From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] tipc: eliminate KASAN warning
Date: Thu, 26 Oct 2017 09:39:01 +0900 (KST)
Message-ID: <20171026.093901.1331155620573390822.davem@davemloft.net>
References: <1508941192-15311-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdJZAjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 20:39:05 -0400
In-Reply-To: <1508941192-15311-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 25 Oct 2017 16:19:52 +0200

> The following warning was reported by syzbot on Oct 24. 2017:
> KASAN: slab-out-of-bounds Read in tipc_nametbl_lookup_dst_nodes
> 
> This is a harmless bug, but we still want to get rid of the warning,
> so we swap the two conditions in question.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
