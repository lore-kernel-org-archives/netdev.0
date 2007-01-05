From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Thu, 04 Jan 2007 16:57:35 -0800 (PST)
Message-ID: <20070104.165735.102614518.davem@davemloft.net>
References: <20070104200430.149943972@hp.com>
	<20070104200437.008980288@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53206
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932122AbXAEA5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 19:57:36 -0500
To: paul.moore@hp.com
In-Reply-To: <20070104200437.008980288@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul Moore" <paul.moore@hp.com>
Date: Thu, 04 Jan 2007 15:04:31 -0500

> From: Paul Moore <paul.moore@hp.com>
> 
> The inet_create() and inet6_create() functions incorrectly set the
> inet_sock->is_icsk field.  Both functions assume that the is_icsk field is
> large enough to hold at least a INET_PROTOSW_ICSK value when it is actually
> only a single bit.  This patch corrects the assignment by doing a boolean
> comparison whose result will safely fit into a single bit field.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied, thanks a lot Paul.
