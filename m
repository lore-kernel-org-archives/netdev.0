From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/12] NET: fix subqueue bugs
Date: Tue, 23 Oct 2007 15:38:36 -0700 (PDT)
Message-ID: <20071023.153836.85407923.davem@davemloft.net>
References: <tueoct232007613pm.likjasfdlkjdas987@havoc.gtf.org>
	<20071023223646.550241F81B7@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49480
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754538AbXJWWiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 18:38:09 -0400
In-Reply-To: <20071023223646.550241F81B7@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 23 Oct 2007 18:36:46 -0400 (EDT)

> net/sched/sch_prio.c: In function $,1rx(Bprio_dequeue$,1ry(B:
> net/sched/sch_prio.c:139: warning: passing argument 2 of $,1rx(Bnetif_subqueue_stopped$,1ry(B makes pointer from integer without a cast
> net/sched/sch_prio.c: In function $,1rx(Brr_dequeue$,1ry(B:
> net/sched/sch_prio.c:169: warning: passing argument 2 of $,1rx(Bnetif_subqueue_stopped$,1ry(B makes pointer from integer without a cast
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

I have another copy of this from Pavel earlier in my inbox
and I promise I will integrate his patch today :-)
