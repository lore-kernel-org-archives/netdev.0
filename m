From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/1] hv_netvsc: call dump_rndis_message() only
 in netvsc debug mode
Date: Tue, 21 Apr 2015 20:30:13 -0400 (EDT)
Message-ID: <20150421.203013.1642320994735532678.davem@davemloft.net>
References: <1429657085-23379-1-git-send-email-sixiao@microsoft.com>
	<20150421.174852.1894618346723165016.davem@davemloft.net>
	<CY1PR03MB137672BCD670AF429263C498C4EF0@CY1PR03MB1376.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sixiao@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CY1PR03MB137672BCD670AF429263C498C4EF0@CY1PR03MB1376.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Xiao <sixiao@microsoft.com>
Date: Tue, 21 Apr 2015 22:14:14 +0000

> In current netvsc driver, for each packet received, it will call
> dump_rndis_message() to try to dump the rndis packet information by
> netdev_dbg().  In non-debug mode, dump_rndis_message() will not dump
> anything but it still initialize some local variables and process
> the switch logic in the function of dump_rndis_message(), which is
> unnecessary, especially in high network throughput situation.

See NETIF_MSG_* and use it properly in your driver, read other drivers
and learn how to properly use it for things like this.

I'm not going to explain this a third time.
