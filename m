From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: optimize
 tlb_get_least_loaded_slave
Date: Wed, 02 Jun 2010 04:17:26 -0700 (PDT)
Message-ID: <20100602.041726.133421443.davem@davemloft.net>
References: <20100519132638.GC2788@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757859Ab0FBLRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 07:17:17 -0400
In-Reply-To: <20100519132638.GC2788@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 19 May 2010 15:26:39 +0200

> In the worst case, when the first loop breaks an the end of the slave list,
> the slave list is iterated through twice. This patch reduces this
> function only to one loop. Also makes it simpler.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
