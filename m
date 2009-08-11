From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Tue, 11 Aug 2009 16:57:41 -0700
Message-ID: <1250035061.30166.42.camel@localhost.localdomain>
References: <1249985224.13065.11.camel@HunTEr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Thomas Graf <tgraf@suug.ch>,
	linux-next <linux-next@vger.kernel.org>
To: vibi_sreenivasan@cms.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57378 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbZHKX6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 19:58:02 -0400
In-Reply-To: <1249985224.13065.11.camel@HunTEr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vibi,

> net/netlink/genetlink.c: In function `genl_register_mc_group':
> net/netlink/genetlink.c:139: warning: 'err' might be used uninitialized in this function
> 
> Signed-off-by: vibi sreenivasan <vibi_sreenivasan@cms.com>
> ---
>  net/netlink/genetlink.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 575c643..66f6ba0 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *family,
>  {
>         int id;
>         unsigned long *new_groups;
> -       int err;
> +       int err = 0;
>  
>         BUG_ON(grp->name[0] == '\0');

this looks fishy. How does gcc thinks this variable is uninitialized. If
I look at the code in Linus' tree, I don't see it.

Regards

Marcel


