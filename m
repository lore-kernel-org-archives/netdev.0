From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] qlcnic: Refactoring - template based hardware
 interface
Date: Fri, 31 Aug 2012 16:05:17 -0400 (EDT)
Message-ID: <20120831.160517.226136265278963899.davem@davemloft.net>
References: <1346394541-3486-1-git-send-email-sony.chacko@qlogic.com>
	<1346394541-3486-2-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	anirban.chakraborty@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848Ab2HaUFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:05:20 -0400
In-Reply-To: <1346394541-3486-2-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Fri, 31 Aug 2012 02:28:50 -0400

> +static inline int
> +qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
> +{
> +	return adapter->nic_ops->config_bridged_mode(adapter, enable);
> +
> +}
> +
> +static inline int
> +qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
> +{
> +	return adapter->nic_ops->config_led(adapter, state, rate);
> +
> +}
> +

Please get rid of those unnecessary empty lines in the function bodies.
