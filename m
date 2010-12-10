From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v16 03/17] Add a ndo_mp_port_prep pointer to
 net_device_ops.
Date: Fri, 10 Dec 2010 12:36:57 -0800 (PST)
Message-ID: <20101210.123657.15226119.davem@davemloft.net>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1291187695.git.xiaohui.xin@intel.com>
	<fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1291187695.git.xiaohui.xin@intel.com>
	<cd0686f2b8fc16a1d87ced228b2a90b93f008b94.1291187695.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33630
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756992Ab0LJUg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 15:36:29 -0500
In-Reply-To: <cd0686f2b8fc16a1d87ced228b2a90b93f008b94.1291187695.git.xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: xiaohui.xin@intel.com
Date: Wed,  1 Dec 2010 16:08:14 +0800

> +#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
> +	int			(*ndo_mp_port_prep)(struct net_device *dev,
> +						struct mp_port *port);
> +#endif

Please rename this config option so that it is clear, by name, that
this option is for a networking facility.

F.e. CONFIG_NET_MEDIATE_PASSTHRU
