From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netlink: rate-limit leftover bytes warning and
 print process name
Date: Mon, 02 Jun 2014 11:16:35 -0700 (PDT)
Message-ID: <20140602.111635.913397323108457409.davem@davemloft.net>
References: <53889525.3080506@cogentembedded.com>
	<1401726302-21240-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	nicolas.dichtel@6wind.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbaFBSQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 14:16:36 -0400
In-Reply-To: <1401726302-21240-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Mon,  2 Jun 2014 18:25:02 +0200

> Any process is able to send netlink messages with leftover bytes.
> Make the warning rate-limited to prevent too much log spam.
> 
> The warning is supposed to help find userspace bugs, so print the
> triggering command name to implicate the buggy program.
> 
> [v2: Use pr_warn_ratelimited instead of printk_ratelimited.]
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thanks Michal.
