From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sock: introduce SO_MEMINFO getsockopt
Date: Wed, 22 Mar 2017 11:20:24 -0700 (PDT)
Message-ID: <20170322.112024.157764600434310885.davem@davemloft.net>
References: <1490037723-6475-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jbaron@akamai.com,
        ckuiper@google.com, pgynther@google.com
To: johunt@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934813AbdCVSUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:20:25 -0400
In-Reply-To: <1490037723-6475-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>
Date: Mon, 20 Mar 2017 15:22:03 -0400

> Allows reading of SK_MEMINFO_VARS via socket option. This way an
> application can get all meminfo related information in single socket
> option call instead of multiple calls.
> 
> Adds helper function, sk_get_meminfo(), and uses that for both
> getsockopt and sock_diag_put_meminfo().
> 
> Suggested by Eric Dumazet.
> 
> Signed-off-by: Josh Hunt <johunt@akamai.com>
> Reviewed-by: Jason Baron <jbaron@akamai.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
