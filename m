From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v9 3/9] net: nl802154 -
 make add_iface take name assign type
Date: Thu, 17 Jul 2014 16:19:31 -0700 (PDT)
Message-ID: <20140717.161931.283488873926282207.davem@davemloft.net>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
	<1405584370-30054-4-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: teg-B22kvLQNl6c@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1405584370-30054-4-git-send-email-teg-B22kvLQNl6c@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Date: Thu, 17 Jul 2014 10:06:04 +0200

> @@ -192,8 +193,10 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
>  		if (devname[nla_len(info->attrs[IEEE802154_ATTR_DEV_NAME]) - 1]
>  				!= '\0')
>  			return -EINVAL; /* phy name should be null-terminated */
> +		name_assign_type = NET_NAME_USER;
>  	} else  {
>  		devname = "wpan%d";
> +		name_assign_type = NET_NAME_ENUM;
>  	}
>  
>  	if (strlen(devname) >= IFNAMSIZ)

Just wondering what should happen if "%d" appears in a user provided name.

That would seem to be both USER and ENUM.

------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
