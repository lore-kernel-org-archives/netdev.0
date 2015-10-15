From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] netlink: Rightsize IFLA_AF_SPEC size
 calculation
Date: Wed, 14 Oct 2015 19:24:22 -0700 (PDT)
Message-ID: <20151014.192422.1272488031691006858.davem@davemloft.net>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
	<1444837888-32656-1-git-send-email-ronen.arad@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865AbbJOCIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 22:08:17 -0400
In-Reply-To: <1444837888-32656-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ronen Arad <ronen.arad@intel.com>
Date: Wed, 14 Oct 2015 08:51:28 -0700

> @@ -900,7 +901,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>  	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
>  	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>  	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
> -	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
> +		+ rtnl_link_get_af_size(dev, ext_filter_mask) /* IFLA_AF_SPEC */
>  	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */

Please don't change the indentation on this line, keep it matching
the indentation of all of the surrounding lines of this expression.

Thanks.
