From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: use del_timer_sync() in sfq_destroy()
Date: Sun, 27 Apr 2008 20:24:34 +0200
Message-ID: <4814C4E2.50600@trash.net>
References: <20080427125921.GA7480@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64480 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758631AbYD0S2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 14:28:42 -0400
In-Reply-To: <20080427125921.GA7480@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> [NET_SCHED] sch_sfq: use del_timer_sync() in sfq_destroy()
>
> Let's delete timer reliably in sfq_destroy().

This is broken, we hold dev->queue_lock in ->destroy.

