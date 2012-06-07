From: David Miller <davem@davemloft.net>
Subject: Re: Remove out of date message in appletalk printk
Date: Thu, 07 Jun 2012 13:12:55 -0700 (PDT)
Message-ID: <20120607.131255.439288998037331522.davem@davemloft.net>
References: <20120606184559.GA27763@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab2FGUM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:12:56 -0400
In-Reply-To: <20120606184559.GA27763@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 6 Jun 2012 14:45:59 -0400

> I accidentally triggered this printk, which amused me for a few moments.
> Given we're post 2.2, we could just -EACCES, but does anyone even care about Appletalk now ?
> I figure it's better to leave sleeping dogs lie, and just update the message.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied, but I made a few refinements.  I made it use pr_warn() and
also prefixed the message with "atalk_connect: " so if someone sees
this it's easier to figure out where it's coming from.

Thanks.
