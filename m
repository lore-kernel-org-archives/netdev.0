From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 03:35:02 -0700 (PDT)
Message-ID: <20110622.033502.2198841895093553350.davem@davemloft.net>
References: <20110621225645.GD16021@Chamillionaire.breakpoint.cc>
	<20110621.155816.1840729860084652508.davem@davemloft.net>
	<4E01C34F.6050009@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, fbl@redhat.com, netdev@vger.kernel.org,
	agospoda@redhat.com, nhorman@redhat.com, lwoodman@redhat.com
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab1FVKfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 06:35:11 -0400
In-Reply-To: <4E01C34F.6050009@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 22 Jun 2011 06:26:23 -0400

> Using the netfilter xt-SYSRQ code seems to store the entered code and
> execute it later after the system has returned to a normal state....
> which is much too late to be useful.

So add a feature that allows xt-SYSRQ to not queue the request
and instead execute it immediately in softirq context.

I don't see what the big deal is.
