From: David Miller <davem@davemloft.net>
Subject: Re: trying to track a change to drivers/isdn/usb-gigaset.c
Date: Mon, 07 May 2007 03:41:17 -0700 (PDT)
Message-ID: <20070507.034117.115910272.davem@davemloft.net>
References: <463EF77A.9020808@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@redhat.com,
	netdev@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37101
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932203AbXEGKlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 06:41:14 -0400
In-Reply-To: <463EF77A.9020808@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Mon, 07 May 2007 11:55:06 +0200

[ netdev@vger.kernel.org is the place to discuss kernel networking
  issues, thanks ]

> But I cannot remember seeing that patch via the maintainer
> addresses for ISDN or the Gigaset driver, and the LKML archive
> doesn't seem to have it either.
> 
> Where was that patch discussed? What is its rationale?

This was a wholesale change done across the entire tree, they were all
straightforward transformations that didn't change what the code did.

It was a change done so that we could hide the skb data buffering
details to the point where we could change the protocol header
pointers into 32-bit offsets which saves 4 bytes per such pointer per
protocol header stored in struct sk_buff.

We're not going to notify the maintainer of each of the hundreds of
source files we had to touch in order to pull this off, sorry.

These changes were posted to netdev@vger.kernel.org, they also
sat in Andrew Morton's -mm tree for quite some time.
