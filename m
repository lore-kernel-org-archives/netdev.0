From: David Miller <davem@davemloft.net>
Subject: Re: net: sctp: sctp_auth_key_put: use kzfree instead of
 kfree
Date: Mon, 15 Apr 2013 14:26:25 -0400 (EDT)
Message-ID: <20130415.142625.2268142531404130811.davem@davemloft.net>
References: <1365984180.2783.86.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	dborkman@redhat.com, spender@grsecurity.net
To: ben@decadent.org.uk
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1365984180.2783.86.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 15 Apr 2013 01:03:00 +0100

> Brad Spengler pointed out there was one missing, which seems to be this
> one:
> 
> commit 586c31f3bf04c290dc0a0de7fc91d20aa9a5ee53
> Author: Daniel Borkmann <dborkman@redhat.com>
> Date:   Thu Feb 7 00:55:37 2013 +0000
> 
>     net: sctp: sctp_auth_key_put: use kzfree instead of kfree
> 
> I assume that was an accidental omission, in which case please include
> it the next batch.

Thanks for catching this, I've re-queued it up.
