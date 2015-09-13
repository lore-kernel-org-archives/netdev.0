From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] net-sysfs: get_netdev_queue_index() cleanup
Date: Sun, 13 Sep 2015 08:46:26 +0300
Message-ID: <55F50DB2.4080009@mellanox.com>
References: <1442002119-15823-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0075.outbound.protection.outlook.com ([157.56.112.75]:23872
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751055AbbIMGCT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Sep 2015 02:02:19 -0400
In-Reply-To: <1442002119-15823-1-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/11/2015 11:08 PM, Thadeu Lima de Souza Cascardo wrote:
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

Please use here a --abbrev=12 generated short log e.g

Fixes: 22b3b2ebfff ('net: Add max rate tx queue attribute')

> Cc: Or Gerlitz <ogerlitz@mellanox.com>

remove the Cc: line for me and add this one (hate to see myself 
mentioned twice here...)

Acked-by:  Or Gerlitz <ogerlitz@mellanox.com>

Good catch!
