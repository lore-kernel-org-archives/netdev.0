From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: snmp: fix the wrong ICMP_MIB_MAX value
Date: Wed, 01 Dec 2010 12:35:50 -0800 (PST)
Message-ID: <20101201.123550.15237244.davem@davemloft.net>
References: <4CF34E03.8020504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51941
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756773Ab0LAUfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 15:35:24 -0500
In-Reply-To: <4CF34E03.8020504@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Mon, 29 Nov 2010 14:53:55 +0800

> @@ -60,8 +60,7 @@ struct ipstats_mib {
>  };
>  
>  /* ICMP */
> -#define ICMP_MIB_MAX	(__ICMP_MIB_MAX + 1)
> -
> +#define ICMP_MIB_MAX	__ICMP_MIB_MAX
>  struct icmp_mib {

In all of my trees there is an "ICMP_MIB_DUMMY" define here, and it's
been there forever, I have no idea what you are patching against.
