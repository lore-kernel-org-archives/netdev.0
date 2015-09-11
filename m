From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net-sysfs: get_netdev_queue_index() cleanup
Date: Fri, 11 Sep 2015 13:20:17 -0700
Message-ID: <55F33781.1030405@gmail.com>
References: <1442002119-15823-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34791 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbbIKUSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 16:18:40 -0400
Received: by oiev17 with SMTP id v17so49080210oie.1
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 13:18:40 -0700 (PDT)
In-Reply-To: <1442002119-15823-1-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-09-11 01:08 PM, Thadeu Lima de Souza Cascardo wrote:
> Redo commit ed1acc8cd8c22efa919da8d300bab646e01c2dce.
> 
> Commit 822b3b2ebfff8e9b3d006086c527738a7ca00cd0 ("net: Add max rate tx queue
> attribute") moved get_netdev_queue_index around, but kept the old version.
> Probably because of a reuse of the original patch from before Eric's change to
> that function.
> 
> Remove one inline keyword, and no need for a loop to find
> an index into a table.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> Fixes: 822b3b2ebfff8e9b3d006086c527738a7ca00cd0
> Cc: Or Gerlitz <ogerlitz@mellanox.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
> 
> Not sure what is the best way to credit Eric Dumazet here. I assume he will add
> any appropriate tags.
> 

Yep, I guess Or just overlooked this and I missed it in the review when
the patch was submitted.

Thanks!

Acked-by: John Fastabend <john.r.fastabend@intel.com>
