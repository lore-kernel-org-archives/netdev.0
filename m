From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: rate-limit leftover bytes warning and print
 process name
Date: Fri, 30 May 2014 17:16:24 -0700 (PDT)
Message-ID: <20140530.171624.1737602003205792918.davem@davemloft.net>
References: <5385DAE5.2020009@6wind.com>
	<1401454647-28228-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934638AbaEaAQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:16:25 -0400
In-Reply-To: <1401454647-28228-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 30 May 2014 14:57:27 +0200

> Any process is able to send netlink messages with leftover bytes.
> Make the warning rate-limited to prevent too much log spam.
> 
> The warning is supposed to help find userspace bugs, so print the
> triggering command name to implicate the buggy program.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Please use pr_warn_ratelimited() as suggested by Sergei.

Thanks.
