From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: fix tp_reserve race in packet_set_ring
Date: Thu, 10 Aug 2017 09:52:39 -0700 (PDT)
Message-ID: <20170810.095239.721704501665711181.davem@davemloft.net>
References: <20170810164158.52213-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@gmail.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752520AbdHJQwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:52:40 -0400
In-Reply-To: <20170810164158.52213-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu, 10 Aug 2017 12:41:58 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Updates to tp_reserve can race with reads of the field in
> packet_set_ring. Avoid this by holding the socket lock during
> updates in setsockopt PACKET_RESERVE.
> 
> This bug was discovered by syzkaller.
> 
> Fixes: 8913336a7e8d ("packet: add PACKET_RESERVE sockopt")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Also applied and queued up for -stable, thanks Willem.
