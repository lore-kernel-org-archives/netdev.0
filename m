From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: select current active slave when enslaving
 device for mode tlb and alb
Date: Wed, 25 Mar 2009 17:24:03 -0700 (PDT)
Message-ID: <20090325.172403.37379149.davem@davemloft.net>
References: <20090325155022.GJ3437@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, jgarzik@pobox.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752693AbZCZAYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 20:24:15 -0400
In-Reply-To: <20090325155022.GJ3437@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 25 Mar 2009 16:50:23 +0100

> This patch calls bond_select_active_slave() in bond_enslave()
> function for modes alb and tlb and makes sure that the current
> active slave is set up properly even when the slave state is already
> up. Tested on both systems, works fine.
> 
> Notice: The same problem can maybe also occrur in mode 8023AD but
> I'm unable to test that.

Looks good, applied, thanks!
