From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work properly
 in bridge -try4
Date: Mon, 30 Mar 2009 14:04:25 +0200
Message-ID: <49D0B549.3050900@trash.net>
References: <20090326155205.GA28868@psychotron.englab.brq.redhat.com>	<20090327.003819.234492275.davem@davemloft.net>	<49CC85E9.7070903@trash.net> <20090329.135355.109115565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59367 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbZC3ME2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 08:04:28 -0400
In-Reply-To: <20090329.135355.109115565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 27 Mar 2009 08:53:13 +0100
> 
>> ... an alternative approach
>> would be to have bonding add FDB entries for all secondary MACs to
>> make bridging treat them as local.
> 
> Do you guys foresee any possibility of an alternative implementation
> any time soon?
> 
> Otherwise we're just stalling by not putting something into the tree,
> and as far as I can tell this patch here might as well be it.

Adding bridge FDB entries seems like the best fix. It might
need some minor ugliness to avoid new dependencies between
bonding and bridging, but it definitely beats having new hooks
in the core in my opinion.

But I have no idea whether Jiri is actually implementing this.
