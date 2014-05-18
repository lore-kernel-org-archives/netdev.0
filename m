From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 4/4] macvlan: Fix lockdep warnings with stacked
 macvlan devices
Date: Sun, 18 May 2014 17:36:33 +0100
Message-ID: <20140518163632.GA8796@macbook.localnet>
References: <1400274296-14765-1-git-send-email-vyasevic@redhat.com>
 <1400274296-14765-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com, vfalico@gmail.com,
	jiri@resnulli.us
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48038 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbaERQgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 12:36:38 -0400
Content-Disposition: inline
In-Reply-To: <1400274296-14765-5-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 05:04:56PM -0400, Vlad Yasevich wrote:
> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index 7c8b20b..a9a53b1 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -56,6 +56,7 @@ struct macvlan_dev {
>  	int			numqueues;
>  	netdev_features_t	tap_features;
>  	int			minor;
> +	int			nest_level;
>  };

Please use unsigned int as for 802.1q since this can't be negative.
