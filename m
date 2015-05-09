From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] tipc: fix default link prop regression in
 nl compat
Date: Sat, 09 May 2015 16:40:13 -0400 (EDT)
Message-ID: <20150509.164013.1050929474625068908.davem@davemloft.net>
References: <1430913536-4206-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbbEIUkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:40:16 -0400
In-Reply-To: <1430913536-4206-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Wed, 6 May 2015 13:58:54 +0200

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> Default link properties can be set for media or bearer. This
> functionality was missed when introducing the NL compatibility layer.
> 
> This patch implements this functionality in the compat netlink
> layer. It works the same way as it did in the old API. We search for
> media and bearers matching the "link name". If we find a matching
> media or bearer the link tolerance, priority or window is used as
> default for new links on that media or bearer.
> 
> Fixes: 37e2d4843f9e (tipc: convert legacy nl link prop set to nl compat)
> Reported-by: Tomi Ollila <tomi.ollila@iki.fi>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied.
