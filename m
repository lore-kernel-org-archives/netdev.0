From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] drivers: net: Don't print unpopulated
 net_device name
Date: Tue, 17 May 2016 12:31:21 -0400 (EDT)
Message-ID: <20160517.123121.1984109840595169844.davem@davemloft.net>
References: <1463492007-12013-1-git-send-email-harvey.hunt@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@ziswiler.com, robert.jarzmik@free.fr, Baohua.Song@csr.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: harvey.hunt@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274AbcEQQbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 12:31:24 -0400
In-Reply-To: <1463492007-12013-1-git-send-email-harvey.hunt@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Hunt <harvey.hunt@imgtec.com>
Date: Tue, 17 May 2016 14:33:27 +0100

> For ethernet devices, net_device.name will be eth%d before
> register_netdev() is called. Don't print the net_device name until
> the format string is replaced.
> 
> Signed-off-by: Harvey Hunt <harvey.hunt@imgtec.com>
> Cc: Marcel Ziswiler <marcel@ziswiler.com>
> Cc: Robert Jarzmik <robert.jarzmik@free.fr>
> Cc: Barry Song <Baohua.Song@csr.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org 
> ---
> v1 -> v2:
>  - Replace ifconfig with ip
>  - Delay printk until the netdev name is known

Yeah this looks a lot better, applied, thanks!
