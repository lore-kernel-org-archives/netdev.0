From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [rfc] new sk_buff member: hwstamp
Date: Mon, 14 Jul 2008 19:25:59 +0200
Message-ID: <87abgkz8bc.fsf@basil.nowhere.org>
References: <200807141843.00845.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:7321 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494AbYGNR0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 13:26:22 -0400
In-Reply-To: <200807141843.00845.opurdila@ixiacom.com> (Octavian Purdila's message of "Mon, 14 Jul 2008 18:43:00 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila <opurdila@ixiacom.com> writes:

> So, would such a patch be considered for inclusion? Or maybe there is a 
> better way of doing the above?

You only need this between the driver and the socket recvmsg(), don't you?

One possible alternative (I admit I haven't thought all the implications
through) would be to use a second magic internal skb for this which has the 
same UDP header, but as only payload the time stamp. Disadvantage would
be the requirement to do header parsing in the driver, but often
hardware does that already.

-Andi
