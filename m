From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] ethtool: rename reserved1 memeber in
 ethtool_drvinfo for expansion ROM version
Date: Sat, 07 Feb 2015 21:57:36 -0800 (PST)
Message-ID: <20150207.215736.2234534604308936993.davem@davemloft.net>
References: <1423054176-26420-1-git-send-email-hariprasad@chelsio.com>
	<1423054176-26420-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbBHF5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 00:57:44 -0500
In-Reply-To: <1423054176-26420-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  4 Feb 2015 18:19:34 +0530

> Renamed the reserved1 member of struct ethtool_drvinfo to erom_version to get
> expansion/option ROM version of the adapter if present.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
 ...
> @@ -148,6 +148,7 @@ static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
>   *	not be an empty string.
>   * @version: Driver version string; may be an empty string
>   * @fw_version: Firmware version string; may be an empty string
> + * @erom_version: Expansion ROM version string; may be an empty string
>   * @bus_info: Device bus address.  This should match the dev_name()
>   *	string for the underlying bus device, if there is one.  May be
>   *	an empty string.
> @@ -176,7 +177,7 @@ struct ethtool_drvinfo {
>  	char	version[32];
>  	char	fw_version[ETHTOOL_FWVERS_LEN];
>  	char	bus_info[ETHTOOL_BUSINFO_LEN];
> -	char	reserved1[32];
> +	char	erom_version[32];

Please add a define like ETHTOOL_FWVERS_LEN and ETHTOOL_BUSINFO_LEN
and use it here.
