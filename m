From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix uninitialised variable in ip_frag_reasm()
Date: Wed, 17 Oct 2007 21:37:33 -0700 (PDT)
Message-ID: <20071017.213733.21235115.davem@davemloft.net>
References: <20071017150248.22323.39167.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751783AbXJREhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:37:34 -0400
In-Reply-To: <20071017150248.22323.39167.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Wed, 17 Oct 2007 16:02:48 +0100

> Fix uninitialised variable in ip_frag_reasm().  err should be set to -ENOMEM
> if the initial call of skb_clone() fails.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
