From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: move slave MTU handling from sysfs V2
Date: Thu, 20 May 2010 11:21:59 -0700
Message-ID: <32283.1274379719@death.nxdomain.ibm.com>
References: <20100518154016.GD2878@psychotron.lab.eng.brq.redhat.com> <628.1274314061@death.nxdomain.ibm.com> <20100520053403.GA2867@psychotron.redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bonding-devel@lists.sourceforge.net, monis@voltaire.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:51177 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754113Ab0ETSWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 14:22:04 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4KI9LXl016552
	for <netdev@vger.kernel.org>; Thu, 20 May 2010 14:09:21 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4KIM3fi107090
	for <netdev@vger.kernel.org>; Thu, 20 May 2010 14:22:03 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4KIM1Z8023762
	for <netdev@vger.kernel.org>; Thu, 20 May 2010 15:22:02 -0300
In-reply-to: <20100520053403.GA2867@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>Thu, May 20, 2010 at 02:07:41AM CEST, fubar@us.ibm.com wrote:
[...]
>>	This chunk doesn't apply to net-next-2.6 because your context
>>doesn't match; it looks like you've removed the variable "found" in your
>>"before" source.  On closer inspection, "found" isn't actually used
>>meaningfully, so I'm guessing you removed it in a prior patch but didn't
>>submit that patch.
>>
>>	If that's the case, could you repost the whole series, with
>>sequence numbers?
>
>I don't think that's necessary for now. The patch removing found was posted as a
>first one:
>http://patchwork.ozlabs.org/patch/52795/
>
>I tried it several times. Patches are cleanly applicable in order I posted it.

	Ok, I tracked down a copy (not sure where mine went).  Sequence
numbers do help in general, though, as a set of email messages aren't
always delivered in the same order they're sent.

	In any event, the patches all look ok to me (they do apply
cleanly and compile, now that I have the complete set), but none of them
are bug fixes, and should therefore probably wait until net-next
reopens.  

	So, for whenever the tree is open:

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
