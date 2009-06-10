From: Roland Dreier <rdreier@cisco.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Tue, 09 Jun 2009 20:55:57 -0700
Message-ID: <ada1vps4u9e.fsf@cisco.com>
References: <alpine.DEB.1.10.0906081117580.21954@gentwo.org>
	<20090608.142927.122160930.davem@davemloft.net>
	<adaocsx3zaa.fsf@cisco.com>
	<20090609.174504.114047526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:29798 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbZFJDzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 23:55:55 -0400
In-Reply-To: <20090609.174504.114047526.davem@davemloft.net> (David Miller's
	message of "Tue, 09 Jun 2009 17:45:04 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Block the process joining the multicast group, not the entire
 > interface.

Hmm... how do I do that?  The interface gets an skb that it sees should
be sent to a multicast group that it is not a member of yet, and so it
fires off a request to join that group (as a send-only member).  How
does a netdev block the process that queued up a given skb to send?
Couldn't the packet have come through a local software bridge or
something like that, so the original process is long since lost to the
network stack?

 - R.
