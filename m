From: David Miller <davem@davemloft.net>
Subject: Re: neighbour table overflow errors. leaking neighbours I think
Date: Fri, 13 Jan 2012 19:13:35 -0800 (PST)
Message-ID: <20120113.191335.878480017420825771.davem@davemloft.net>
References: <CAKedQg_qWUgXzsTrQJ0NGoxzKHaQvAnZ2pztzAXVHbq9H4gLRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brucerjones@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493Ab2ANDNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 22:13:39 -0500
In-Reply-To: <CAKedQg_qWUgXzsTrQJ0NGoxzKHaQvAnZ2pztzAXVHbq9H4gLRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Jones <brucerjones@gmail.com>
Date: Fri, 13 Jan 2012 17:29:59 -0700

> I am seeing neighbour table overflow messages so I began exploring
> neighbour structure reference counts to try and understand the issue
> and see why they are not being reclaimed by the garbage collector.

Every route holds a reference to a neighbour entry, so until the
routes are purged or flushed, the neighbours can't be reclaimed.
