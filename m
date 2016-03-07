From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 2/4] tipc: don't check link reset on non
 existing link
Date: Sun, 06 Mar 2016 22:58:01 -0500 (EST)
Message-ID: <20160306.225801.647777524755725033.davem@davemloft.net>
References: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
	<1457011243-23605-2-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcCGD6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 22:58:04 -0500
In-Reply-To: <1457011243-23605-2-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Thu, 3 Mar 2016 14:20:41 +0100

> Make sure we have a link before checking if it has been reset or not.
> 
> Prior to this patch tipc_link_is_reset() could be called with a non
> existing link, resulting in a null pointer dereference.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@gmail.com>

Applied.
