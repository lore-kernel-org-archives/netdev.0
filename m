From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp_pch: depends on PCI
Date: Sat, 25 May 2013 23:11:29 -0700 (PDT)
Message-ID: <20130525.231129.392417150870789444.davem@davemloft.net>
References: <20130525165507.GE30204@redacted.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: kyle@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab3EZGLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 02:11:32 -0400
In-Reply-To: <20130525165507.GE30204@redacted.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@redhat.com>
Date: Sat, 25 May 2013 12:55:07 -0400

> It's only accessible via PCI, but has no dependencies, so it ends up
> being selected on s390 where a bunch of primitives only exist if
> CONFIG_PCI=y (such as {request,free}_irq)
> 
> Signed-off-by: Kyle McMartin <kyle@redhat.com>

I've already told the s390 people they have to fix this properly.

They have to provide stubs for request_irq() et al. when CONFIG_PCI
is not enabled.

This Kconfig change is therefore not appropriate.
