From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 net-next 07/27] net: add for_each iterators through
 neighbour lower link's private
Date: Tue, 17 Sep 2013 02:26:43 +0100
Message-ID: <1379381203.23881.22.camel@deadeye.wl.decadent.org.uk>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
	 <1379378812-18346-8-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31090 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab3IQB0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:26:48 -0400
In-Reply-To: <1379378812-18346-8-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-17 at 02:46 +0200, Veaceslav Falico wrote:
[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4537,6 +4537,72 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
>  }
>  EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
>  
> +/* netdev_lower_get_next_private - Get the next ->private from the
> + *				   lower neighbour list
[...]

This is not correct kernel-doc syntax.  You must begin the comment like
this:

/**
 * function_name - summary on one physical line, no wrapping allowed

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
