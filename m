From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] rocker: revert back to support for nowait
 processes
Date: Mon, 15 Jun 2015 16:07:13 -0700 (PDT)
Message-ID: <20150615.160713.1499408328026540947.davem@davemloft.net>
References: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com, makita.toshiaki@lab.ntt.co.jp
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754908AbbFOXHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:07:14 -0400
In-Reply-To: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Fri, 12 Jun 2015 21:35:45 -0700

> One of the items removed from the rocker driver in the Spring Cleanup patch
> series was the ability to mark processing in the driver as "no wait" for
> those contexts where we cannot sleep.  Turns out, we have "no wait"
> contexts where we want to program the device and we don't want to defer the
> processing to a process context.  So re-add the ROCKER_OP_FLAG_NOWAIT flag
> to mark such processes, and propagate flags to mem allocator and to the
> device cmd executor.  With NOWAIT, mem allocs are GFP_ATOMIC and device
> cmds are queued to the device, but the driver will not wait (sleep) for the
> response back from the device.
> 
> My bad for removing NOWAIT support in the first place; I thought we could
> swing non-sleep contexts to process context using a work queue, for
> example, but there is push-back to keep processing in original context.

Series applied, thanks Scott.
