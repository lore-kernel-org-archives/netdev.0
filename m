From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge -try4
Date: Mon, 30 Mar 2009 14:52:00 +0200
Message-ID: <20090330125156.GE3438@psychotron.englab.brq.redhat.com>
References: <20090326155205.GA28868@psychotron.englab.brq.redhat.com> <20090327.003819.234492275.davem@davemloft.net> <49CC85E9.7070903@trash.net> <20090329.135355.109115565.davem@davemloft.net> <49D0B549.3050900@trash.net> <20090330124049.GD3438@psychotron.englab.brq.redhat.com> <49D0BF7F.1060305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54638 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbZC3Myi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 08:54:38 -0400
Content-Disposition: inline
In-Reply-To: <49D0BF7F.1060305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 30, 2009 at 02:47:59PM CEST, kaber@trash.net wrote:
> Jiri Pirko wrote:
>> Currently I'm thinking the way. What I have on mind:
>> I would like to add a list into struct net_device to contain all mac addresses
>> of the device. I would also like to use similar interface to handle them as
>> currently is for uc_list and mc_list. However I do not like that these lists are
>> not using standard list_head but they are propriate lists only for this purpose.
>> I'm thinking about converting them to use list_head first. Or maybe ignore them
>> and do the new list for macs in parallel?
>
> Using list_heads in the address lists would require some pretty large
> amount of work since you'd need to convert all the drivers. 

Yes, I'm aware of it...
> I'm all
> in favour of doing this, but I wouldn't make the fix depend on that
> work.

ok so you are suggesting to use the current list struct?
>
