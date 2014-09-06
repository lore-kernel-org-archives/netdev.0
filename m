From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-timestamp: fix allocation error in test
Date: Fri, 05 Sep 2014 17:31:19 -0700 (PDT)
Message-ID: <20140905.173119.380669661103402219.davem@davemloft.net>
References: <1409840145-32723-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaIFAbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:31:20 -0400
In-Reply-To: <1409840145-32723-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu,  4 Sep 2014 10:15:45 -0400

> A buffer is incorrectly zeroed to the length of the pointer. If
> cfg_payload_len < sizeof(void *) this can overwrites unrelated memory.
> The buffer contents are never read, so no need to zero.
> 
> Fixes: 8fe2f761cae9 ("net-timestamp: expand documentation")
> 
> Reported-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.
