From: David Miller <davem@davemloft.net>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet
 addresses
Date: Tue, 17 Apr 2007 13:09:29 -0700 (PDT)
Message-ID: <20070417.130929.59470175.davem@davemloft.net>
References: <4624B44A.9040509@sw.ru>
	<20070417.123135.56861973.davem@davemloft.net>
	<4625263D.1000709@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@sw.ru, netdev@vger.kernel.org, bridge@lists.osdl.org,
	devel@openvz.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46540
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161218AbXDQUJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 16:09:26 -0400
In-Reply-To: <4625263D.1000709@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 17 Apr 2007 12:55:41 -0700

> David Miller wrote:
> > From: Pavel Emelianov <xemul@sw.ru>
> > Date: Tue, 17 Apr 2007 15:49:30 +0400
> >
> >   
> >> From: Evgeny Kravtsunov <emkravts@openvz.org>
> >>
> >> compare_ether_addr() implicitly requires that the addresses
> >> passed are 2-bytes aligned in memory.
> >>
> >> This is not true for br_stp_change_bridge_id() and
> >> br_stp_recalculate_bridge_id() in which one of the addresses
> >> is unsigned char *, and thus may not be 2-bytes aligned.
> >>
> >> Signed-off-by: Evgeny Kravtsunov <emkravts@openvz.org>
> >> Signed-off-by: Kirill Korotaev <dev@openvz.org>
> >> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
> >>     
> >
> > Patch applied, thank you.
> >   
> I had a better way, I'll fix.

You better hurry I want today's fixes I applied out to Linus this
afternoon.
