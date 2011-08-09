From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv3 4/9] macb: convert printk to netdev_ and friends
Date: Tue, 09 Aug 2011 13:20:27 -0700
Message-ID: <1312921227.11924.35.camel@Joe-Laptop>
References: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
	 <1312881411-2376-5-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	plagnioj@jcrosoft.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wondertoys-mx.wondertoys.net ([206.117.179.246]:34086 "EHLO
	labridge.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752412Ab1HIUU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 16:20:29 -0400
In-Reply-To: <1312881411-2376-5-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-09 at 10:16 +0100, Jamie Iles wrote:
> macb is already using the dev_dbg() and friends helpers so use netdev_()
> along with a pr_fmt() definition to make the printing a little cleaner.
[]
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
[]
> @@ -8,6 +8,7 @@
[]
> +#define pr_fmt(fmt) "macb: " fmt

Hi Jamie.

Just trivia.

Please use #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt 
instead.  There would be no output difference.

That'll make it easier to remove later when all of
of these #defines pr_fmt that use just KBUILD_MODNAME
can be removed.

