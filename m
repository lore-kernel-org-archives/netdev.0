From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers: connector: fixed coding style issues
Date: Sat, 14 Jul 2012 13:33:46 -0700
Message-ID: <1342298026.8377.33.camel@joe2Laptop>
References: <1342297608-6872-1-git-send-email-valentin.ilie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org
To: Valentin Ilie <valentin.ilie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47018 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752370Ab2GNUdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 16:33:47 -0400
In-Reply-To: <1342297608-6872-1-git-send-email-valentin.ilie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-14 at 23:26 +0300, Valentin Ilie wrote:
> Fixed checkpatch warnings.
[]
> diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
[]
> @@ -328,8 +328,8 @@ static int __init cn_proc_init(void)
>  	int err;
>  
>  	if ((err = cn_add_callback(&cn_proc_event_id, "cn_proc",
> -	 			   &cn_proc_mcast_ctl))) {
> -		printk(KERN_WARNING "cn_proc failed to register\n");
> +					&cn_proc_mcast_ctl))) {
> +		pr_warn("cn_proc failed to register\n");

I don't believe the first part of this change is a checkpatch
message.  I think it would be better written by hoisting the
function outside the if like:

	err = cn_add_callback(&cn_proc_event_id, "cn_proc", &cn_proc_mcast_ctl)
	if (err) {
		pr_warn("cn_proc failed to register\n");
		return err;
	}
