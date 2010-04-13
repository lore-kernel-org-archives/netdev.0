From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 5/9] ipv4: ipmr: move unres_queue and timer to
 per-namespace data
Date: Tue, 13 Apr 2010 04:10:14 -0700 (PDT)
Message-ID: <20100413.041014.20261770.davem@davemloft.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
	<1271007435-20035-6-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49290
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753020Ab0DMLKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:10:10 -0400
In-Reply-To: <1271007435-20035-6-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Sun, 11 Apr 2010 19:37:11 +0200

> From: Patrick McHardy <kaber@trash.net>
> 
> The unres_queue is currently shared between all namespaces. Following patches
> will additionally allow to create multiple multicast routing tables in each
> namespace. Having a single shared queue for all these users seems to excessive,
> move the queue and the cleanup timer to the per-namespace data to unshare it.
> 
> As a side-effect, this fixes a bug in the seq file iteration functions: the
> first entry returned is always from the current namespace, entries returned
> after that may belong to any namespace.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This looks good.
