From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] be2net: call napi_disable() for all event queues
Date: Thu, 28 Nov 2013 18:51:19 -0500 (EST)
Message-ID: <20131128.185119.922586665796846427.davem@davemloft.net>
References: <1385539172-4744-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab3K1XvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:51:20 -0500
In-Reply-To: <1385539172-4744-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed, 27 Nov 2013 08:59:32 +0100

> The recent be2net commit 6384a4d (adds a support for busy polling)
> introduces a regression that results in kernel crash. It incorrectly
> modified be_close() so napi_disable() is called only for the first queue.
> This breaks a correct pairing of napi_enable/_disable for the rest
> of event queues and causes a crash in subsequent be_open() call.
> 
> v2: Applied suggestions from Sathya
> 
> Fixes: 6384a4d ("be2net: add support for ndo_busy_poll")
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
