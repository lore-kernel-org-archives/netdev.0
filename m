From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] net: add destructor for skb data.
Date: Sat, 5 Apr 2008 17:06:48 +0400
Message-ID: <20080405130647.GA21337@2ka.mipt.ru>
References: <200804052156.05318.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40427 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751820AbYDENHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 09:07:03 -0400
Content-Disposition: inline
In-Reply-To: <200804052156.05318.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sat, Apr 05, 2008 at 09:56:05PM +1000, Rusty Russell (rusty@rustcorp.com.au) wrote:
> If we want to notify something when an skb is truly finished (such as
> for tun vringfd support), we need a destructor on the data.  We don't
> need to add other fields, since we can just allocate extra room at the
> end.

There is skb->destructor already, for your case of vringfd it can be
used safely afaics.

-- 
	Evgeniy Polyakov
