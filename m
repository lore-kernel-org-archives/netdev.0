From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] RXRPC: Use skb_queue_walk_safe()
Date: Thu, 22 May 2008 15:10:56 +0100
Message-ID: <9913.1211465456@redhat.com>
References: <4835457B.3050300@cn.fujitsu.com>
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	NETDEV <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750916AbYEVOLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 10:11:06 -0400
In-Reply-To: <4835457B.3050300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen <wangchen@cn.fujitsu.com> wrote:

> Because the list could be modified inside the loop, use
> skb_queue_walk_safe().

This is unnecessary.  If skb_insert() is called in the loop, the very next
line is a goto that exits the loop immediately.

David
