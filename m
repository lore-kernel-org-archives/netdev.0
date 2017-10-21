From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 4/5] net/ncsi: Enforce failover on link monitor
 timeout
Date: Sat, 21 Oct 2017 01:57:17 +0100 (WEST)
Message-ID: <20171021.015717.969519862483319323.davem@davemloft.net>
References: <20171019024309.13628-1-sam@mendozajonas.com>
        <20171019024309.13628-4-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gwshan@linux.vnet.ibm.com,
        linux-kernel@vger.kernel.org
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019024309.13628-4-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Thu, 19 Oct 2017 13:43:08 +1100

> From: Gavin Shan <gwshan@linux.vnet.ibm.com>
> 
> The NCSI channel has been configured to provide service if its link
> monitor timer is enabled, regardless of its state (inactive or active).
> So the timeout event on the link monitor indicates the out-of-service
> on that channel, for which a failover is needed.
> 
> This sets NCSI_DEV_RESHUFFLE flag to enforce failover on link monitor
> timeout, regardless the channel's original state (inactive or active).
> Also, the link is put into "down" state to give the failing channel
> lowest priority when selecting for the active channel. The state of
> failing channel should be set to active in order for deinitialization
> and failover to be done.
> 
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>

Applied.
