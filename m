From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] flow dissector: correct size of storage for ARP
Date: Mon, 03 Apr 2017 14:47:49 -0700 (PDT)
Message-ID: <20170403.144749.510468372321111720.davem@davemloft.net>
References: <1491248578-12014-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dinan.gunawardena@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, nicolas.iooss_linux@m4x.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbdDCVrv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 17:47:51 -0400
In-Reply-To: <1491248578-12014-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon,  3 Apr 2017 15:42:58 -0400

> The last argument to __skb_header_pointer() should be a buffer large
> enough to store struct arphdr. This can be a pointer to a struct arphdr
> structure. The code was previously using a pointer to a pointer to
> struct arphdr.
> 
> By my counting the storage available both before and after is 8 bytes on
> x86_64.
> 
> Fixes: 55733350e5e8 ("flow disector: ARP support")
> Reported-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied and queued up for -stable.

> this problem is present in both net, since v4.11-rc1 and net-next.
> However, the code has refactored in net-next. I expect this will result
> in a conflict. Let me know if you would like me to post a version for
> net-next too.

I'll sort out the merge hassles into net-next myself, thanks for
letting me know.
