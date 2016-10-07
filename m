From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: make sure that hashes are not send to
 unaware frontends
Date: Fri, 07 Oct 2016 01:38:01 -0400 (EDT)
Message-ID: <20161007.013801.2201234350691558646.davem@davemloft.net>
References: <1475765230-11936-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752652AbcJGFiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 01:38:25 -0400
In-Reply-To: <1475765230-11936-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Thu, 6 Oct 2016 15:47:10 +0100

> In the case when a frontend only negotiates a single queue with xen-
> netback it is possible for a skbuff with a s/w hash to result in a
> hash extra_info segment being sent to the frontend even when no hash
> algorithm has been configured. (The ndo_select_queue() entry point makes
> sure the hash is not set if no algorithm is configured, but this entry
> point is not called when there is only a single queue). This can result
> in a frontend that isunable to handle extra_info segments being given
> such a segment, causing it to crash.
> 
> This patch fixes the problem by gating whether the extra_info is sent
> not only on the presence of a s/w hash, but also on whether the hash
> algorithm has been configured.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

This doesn't apply cleanly to the current 'net' tree, please respin.

Thanks.
