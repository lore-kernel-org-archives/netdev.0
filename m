From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] xfrm: Don't queue retransmitted packets if the
 original is still on the host
Date: Fri, 18 Oct 2013 13:23:45 -0700
Message-ID: <1382127825.3284.37.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381881514.2045.82.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131016094549.GZ7660@secunet.com> <20131016114246.GB7660@secunet.com>
	 <20131018.161908.1422032342884472542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:62903 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203Ab3JRUXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:23:48 -0400
Received: by mail-pd0-f181.google.com with SMTP id y13so5252672pdi.40
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 13:23:47 -0700 (PDT)
In-Reply-To: <20131018.161908.1422032342884472542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-18 at 16:19 -0400, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 16 Oct 2013 13:42:47 +0200
> 
> > It does not make sense to queue retransmitted packets if the
> > original packet is still in some queue of this host. So add
> > a check to xdst_queue_output() and drop the packet if the
> > original packet is not yet sent.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> I have no problems with this, what about you Eric?

It looks fine to me.

Acked-by: Eric Dumazet <edumazet@google.com>
