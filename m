From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] geneve: fix fill_info when using
 collect_metadata
Date: Thu, 25 May 2017 12:51:50 -0400 (EDT)
Message-ID: <20170525.125150.1579581244845816863.davem@davemloft.net>
References: <20170523223727.15307-1-e@erig.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org
To: e@erig.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034889AbdEYQwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:52:02 -0400
In-Reply-To: <20170523223727.15307-1-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Garver <e@erig.me>
Date: Tue, 23 May 2017 18:37:27 -0400

> Since 9b4437a5b870 ("geneve: Unify LWT and netdev handling.") fill_info
> does not return UDP_ZERO_CSUM6_RX when using COLLECT_METADATA. This is
> because it uses ip_tunnel_info_af() with the device level info, which is
> not valid for COLLECT_METADATA.
> 
> Fix by checking for the presence of the actual sockets.
> 
> Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> Signed-off-by: Eric Garver <e@erig.me>

Please target bug fixes at 'net' not 'net-next' unless the bug only
exists in 'net-next'.

I've applied this to 'net' and queued it up for -stable.
