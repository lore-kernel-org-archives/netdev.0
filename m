From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2] ipv6: coding style improvements (remove
 assignment in if statements)
Date: Sun, 23 Nov 2014 13:50:09 -0800
Message-ID: <1416779409.6651.60.camel@perches.com>
References: <1416778123-5803-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0019.hostedemail.com ([216.40.44.19]:57680 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752089AbaKWVuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 16:50:15 -0500
In-Reply-To: <1416778123-5803-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-23 at 21:28 +0000, Ian Morris wrote:
> This change has no functional impact and simply addresses some coding
> style issues detected by checkpatch. Specifically this change
> adjusts "if" statements which also include the assignment of a
> variable.

Unrelated trivia:

>  net/ipv6/addrconf.c      | 12 ++++++++----
[]
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
[]
> @@ -2690,7 +2691,8 @@ static void init_loopback(struct net_device *dev)
>  
>  	ASSERT_RTNL();
>  
> -	if ((idev = ipv6_find_idev(dev)) == NULL) {
> +	idev = ipv6_find_idev(dev);
> +	if (idev == NULL) {
>  		pr_debug("%s: add_dev failed\n", __func__);
>  		return;
>  	}
> @@ -2813,7 +2815,8 @@ static void addrconf_sit_config(struct net_device *dev)
>  	 * our v4 addrs in the tunnel
>  	 */
>  
> -	if ((idev = ipv6_find_idev(dev)) == NULL) {
> +	idev = ipv6_find_idev(dev);
> +	if (idev == NULL) {
>  		pr_debug("%s: add_dev failed\n", __func__);
>  		return;
>  	}
> @@ -2837,7 +2840,8 @@ static void addrconf_gre_config(struct net_device *dev)
>  
>  	ASSERT_RTNL();
>  
> -	if ((idev = ipv6_find_idev(dev)) == NULL) {
> +	idev = ipv6_find_idev(dev);
> +	if (idev == NULL) {
>  		pr_debug("%s: add_dev failed\n", __func__);
>  		return;
>  	}

It looks like these should not be "add_dev failed"
but "ipv6_find_idev failed"
