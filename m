From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: fix Mobile IPv6 regression
Date: Fri, 28 May 2010 23:03:02 -0700 (PDT)
Message-ID: <20100528.230302.241910488.davem@davemloft.net>
References: <87hblss92x.fsf@small.ssi.corp>
	<4C00047D.3010404@hp.com>
	<4C0008C7.7020302@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arno@natisbad.org, otts@alcatel-lucent.com,
	yoshfuji@linux-ipv6.org, jolsa@redhat.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34381
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751300Ab0E2GCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 02:02:52 -0400
In-Reply-To: <4C0008C7.7020302@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 28 May 2010 14:17:43 -0400

> Commit f4f914b5 (net: ipv6 bind to device issue) caused
> a regression with Mobile IPv6 when it changed the meaning
> of fl->oif to become a strict requirement of the route
> lookup.  Instead, only force strict mode when
> sk->sk_bound_dev_if is set on the calling socket, getting
> the intended behavior and fixing the regression.
> 
> Tested-by: Arnaud Ebalard <arno@natisbad.org>
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied, and queued for -stable, thanks for fixing this.
