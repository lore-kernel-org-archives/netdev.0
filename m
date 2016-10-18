From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: vlan: Use sizeof instead of literal
 number
Date: Mon, 17 Oct 2016 21:36:58 -0400 (EDT)
Message-ID: <20161017.213658.349412154638384827.davem@davemloft.net>
References: <1476752270-12590-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754544AbcJRBhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 21:37:05 -0400
In-Reply-To: <1476752270-12590-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It never makes sense to send the same patch for both net and net-next.

If it's a bug fix, it goes to 'net'.  And it will be eventually
be naturally merged into 'net-next'.

Otherwise, if it's a new feature, cleanup, or optimization it goes to
'net-next'.
