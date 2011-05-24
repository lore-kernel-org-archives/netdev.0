From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 14:29:28 -0700
Message-ID: <20110524142928.105d66ef@nehalam>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37602 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933009Ab1EXV3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 17:29:31 -0400
In-Reply-To: <1306263162-2022-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 May 2011 11:52:42 -0700
Mahesh Bandewar <maheshb@google.com> wrote:

> Define macros to set/clear/test bits for feature set usage. This will eliminate
> the direct use of these fields and enable future ease in managing these fields.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  include/linux/netdev_features.h |  137 +++++++++++++++++++++++++++++++++++++++
>  include/linux/netdevice.h       |   35 ++---------
>  2 files changed, 142 insertions(+), 30 deletions(-)
>  create mode 100644 include/linux/netdev_features.h
> 
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> new file mode 100644
> index 0000000..97bf8c4
> --- /dev/null
> +++ b/include/linux/netdev_features.h
> @@ -0,0 +1,137 @@
> +#ifndef	_NETDEV_FEATURES_H
> +#define	_NETDEV_FEATURES_H
> +
> +/* Forward declarations */
> +struct net_device;
> +
> +typedef	unsigned long *nd_feature_t

typedef'ing a pointer is strongly discouraged by kernel coding style.
You need to use another way such as open coding it.

-- 
