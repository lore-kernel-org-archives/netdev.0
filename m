From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: question on netdev_completed_queue()
Date: Fri, 09 Nov 2012 11:38:30 -0800
Message-ID: <1352489910.19779.770.camel@edumazet-glaptop>
References: <1476426.QTHA7ibVHZ@linux-lqwf.site>
	 <1352407453.2771.18.camel@bwh-desktop.uk.solarflarecom.com>
	 <16131769.FsMAT47cqV@linux-lqwf.site>
	 <1352480979.3159.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:52908 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360Ab2KITic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 14:38:32 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so3046085pbb.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 11:38:32 -0800 (PST)
In-Reply-To: <1352480979.3159.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 17:09 +0000, Ben Hutchings wrote:

> The underlying DQL algorithm doesn't care what it's counting.  However
> the administrator can adjust the queue limits through sysfs, and they
> will expect the numbers to be byte counts.

Yes, skb->len should be a fine approximation, even if slightly wrong for
TSO packets.
