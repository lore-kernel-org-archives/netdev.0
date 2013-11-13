From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Wed, 13 Nov 2013 15:43:14 -0500 (EST)
Message-ID: <20131113.154314.881341992069315387.davem@davemloft.net>
References: <20131112162907.50f0bafa@griffin>
	<20131112.143515.1092879587357986857.davem@davemloft.net>
	<20131113122504.0ddcbf89@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jhs@mojatatu.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab3KMUnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 15:43:16 -0500
In-Reply-To: <20131113122504.0ddcbf89@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 13 Nov 2013 12:25:04 +0100

> I completely agree with this, sorry for not being clear. I just
> understood from the thread that the way to go is to do both, in order
> to not generate too large ACKs for the _new_ code (i.e. for the
> messages that were not plausible before "netlink: allow large data
> transfers from user-space"). I don't know what the "too large" should
> be, though, hence the question.
> 
> But then, if we don't do any capping, the only outcome of a failed
> allocation is the ACK won't be sent and it's clearly stated that
> netlink does not provide reliability. Works for me.

Of course, we should meanwhile add the large SKB handling to the
netlink ACK code.

Therefore, please resubmit your original patch, but modify it as
I asked such that only the ACK code path gets the new large SKB
call.

Thanks.
