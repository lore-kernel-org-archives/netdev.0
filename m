From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 20:12:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1004202003010.13651@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1004201834190.29017@hs20-bc2-1.build.redhat.com>
 <20100420.164505.34362726.davem@davemloft.net>
 <Pine.LNX.4.64.1004201947470.29017@hs20-bc2-1.build.redhat.com>
 <20100420.170038.130590455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab0DUANN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 20:13:13 -0400
In-Reply-To: <20100420.170038.130590455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 20 Apr 2010, David Miller wrote:

> From: Mikulas Patocka <mpatocka@redhat.com>
> Date: Tue, 20 Apr 2010 19:57:45 -0400 (EDT)
> 
> >> We're not reverting the commit you mention, we're going to fix
> >> whatever bug exists instead.
> > 
> > So have a fun searching for them :-/
> 
> When you report a problem and your knee-jerk reaction is "revert this
> commit", expect some push back.

I tried to analyze skb handling and couldn't check correctness of this 
commit. I really think it should be reverted and applied later, when the 
author does it correctly (for example, one bit in the return value to 
indicate consumed/returned skb, other unimportant informational bits).

> We'll instead analyze this bug and take the time to figure out the
> most appropriate course of action.

And do you have any idea what caused it? Why is it using GSO on bridging?

Mikulas
