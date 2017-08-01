From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Avoid going through ->sk_net to access
 the netns
Date: Mon, 31 Jul 2017 18:02:20 -0700 (PDT)
Message-ID: <20170731.180220.2263455500433186111.davem@davemloft.net>
References: <20170731080941.4920-1-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751753AbdHABCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 21:02:21 -0400
In-Reply-To: <20170731080941.4920-1-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Mon, 31 Jul 2017 10:09:41 +0200

> There is no need to go through sk->sk_net to access the net namespace
> and its sysctl variables because we allocate the sock and initialize
> sk_net just a few lines earlier in the same routine.
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Applied, thanks.
