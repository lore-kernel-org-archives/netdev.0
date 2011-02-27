From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 02/10] ethtool: add ntuple flow specifier
 to network flow classifier
Date: Sat, 26 Feb 2011 16:05:47 -0800 (PST)
Message-ID: <20110226.160547.193715938.davem@davemloft.net>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
	<20110225233249.7920.70334.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52389
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750999Ab1B0AFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 19:05:11 -0500
In-Reply-To: <20110225233249.7920.70334.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 25 Feb 2011 15:32:49 -0800

> @@ -396,8 +411,10 @@ struct ethtool_rx_flow_spec {
>  		struct ethtool_ah_espip4_spec		esp_ip4_spec;
>  		struct ethtool_usrip4_spec		usr_ip4_spec;
>  		struct ethhdr				ether_spec;
> +		struct ethtool_ntuple_spec_ext		ntuple_spec;
>  		__u8					hdata[72];
>  	} h_u, m_u;
> +	__u32		flow_type_ext;
>  	__u64		ring_cookie;
>  	__u32		location;
>  };

How can you add this flow_type_ext member to this user visible structure
without utterly breaking userspace?  It changes the offsets of the
ring_cookie and location members.

