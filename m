From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Is skb->queue_mapping valid for received packets?
Date: Mon, 13 Jun 2011 22:16:31 -0400
Message-ID: <20110614021631.GK21309@gospo.rdu.redhat.com>
References: <4DF6C091.5050301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46476 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899Ab1FNCQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 22:16:33 -0400
Content-Disposition: inline
In-Reply-To: <4DF6C091.5050301@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2011 at 06:59:45PM -0700, Ben Greear wrote:
>
> Anyone know if skb->queue_mapping is set for incoming packets, ie to
> notify which queue they came in on?  I can't find it set anywhere,
> and it appears it is sometimes set to 1 when it should be 0 in
> my system.
>
> Maybe it's never actually set, and I'm just reading some stale
> data?
>
> Thanks,
> Ben

Yes, it is set by calls to skb_record_rx_queue in various multiqueue-
capable ethernet drivers.  Where are you checking it and seeing the
incorrect value?

