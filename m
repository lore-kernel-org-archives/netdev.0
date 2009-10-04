From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] connector: Provide the sender's credentials to the
 callback
Date: Sun, 4 Oct 2009 14:53:49 -0700
Message-ID: <20091004145349.bc7b1857.akpm@linux-foundation.org>
References: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com>
	<1254235692-1631-2-git-send-email-philipp.reisner@linbit.com>
	<1254235692-1631-3-git-send-email-philipp.reisner@linbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Lars Ellenberg <lars.ellenberg@linbit.com>
To: Philipp Reisner <philipp.reisner@linbit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49350 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758123AbZJDVyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2009 17:54:32 -0400
In-Reply-To: <1254235692-1631-3-git-send-email-philipp.reisner@linbit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Sep 2009 16:48:09 +0200 Philipp Reisner <philipp.reisner@linbit.com> wrote:

> Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
> Acked-by: Lars Ellenberg <lars.ellenberg@linbit.com>

Please don't send unchangelogged patches.

The title tells us what the patch does, but how is the reader supposed
to work out why it does it?

> diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm-log-userspace-transfer.c
> index ba0edad..556131f 100644
> --- a/drivers/md/dm-log-userspace-transfer.c
> +++ b/drivers/md/dm-log-userspace-transfer.c
> @@ -129,7 +129,7 @@ static int fill_pkg(struct cn_msg *msg, struct dm_ulog_request *tfr)
>   * This is the connector callback that delivers data
>   * that was sent from userspace.
>   */
> -static void cn_ulog_callback(void *data)
> +static void cn_ulog_callback(void *data, struct netlink_skb_parms *nsp)
>  {
>  	struct cn_msg *msg = (struct cn_msg *)data;
>  	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);

Your "connector/dm: Fixed a compilation warning" fix is already in
linux-next, so we throw a small and easily-fixed reject here.


