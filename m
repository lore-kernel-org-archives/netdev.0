From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Discard tcp out-of-order queue if system limit is reached
Date: Tue, 15 Apr 2008 16:58:30 +0200
Message-ID: <4804C296.6000203@firstfloor.org>
References: <200804151854.45021.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50999 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759656AbYDOO6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 10:58:35 -0400
In-Reply-To: <200804151854.45021.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaliy Gusev wrote:
> Hello!
> 
> tcp_prune_queue() doesn't prune an out-of-order queue if socket
> is under rcvbuf. However even if socket is under rcvbuf but system-wide limit is
> reached then skb cannot be queued. It can lead to deadlock situation as any skb that
> fills sequence hole is dropped.
> So discard out-of-order queue if system-wide limit is reached.

Thanks. At least the description makes much more sense than before now.

Acked-by: Andi Kleen <andi@firstfloor.org>

-Andi

