From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] unix_diag: Report memory usage info
Date: Wed, 28 Dec 2011 14:00:52 -0500 (EST)
Message-ID: <20111228.140052.1612142433959503905.davem@davemloft.net>
References: <4EFB1C0E.4060004@parallels.com>
	<4EFB663F.6050009@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab1L1TA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 14:00:57 -0500
In-Reply-To: <4EFB663F.6050009@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 28 Dec 2011 22:55:59 +0400

> On 12/28/2011 05:39 PM, Pavel Emelyanov wrote:
>> Symmetrical to inet sockets, but unix only have two meaningful
>> values -- the wmem allocation and sndbuf.
>> 
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> David, taking into account you don't apply patch #3, please, ignore this and the 5th
> ones

I always toss the entire set of patches when any of the individual
ones need changes.

> (but your feedback about whether reporting the ack backlog info in the same place
> whith the meminfo is still required)

I don't understand what you need to know from me.

The sk_max_ack_backlog needs to stay where it is right now, and I would advise
that you present it in the same way TCP does for other protocols.

What else do you need to know?
