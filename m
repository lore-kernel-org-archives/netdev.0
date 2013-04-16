From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] ks8851: Remove unneeded PM_OPS definitions
Date: Tue, 16 Apr 2013 16:37:50 -0400 (EDT)
Message-ID: <20130416.163750.1652843849557504513.davem@davemloft.net>
References: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
	<1366140511-3836-5-git-send-email-fabio.estevam@freescale.com>
	<516DB4B1.9050602@metafoo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, netdev@vger.kernel.org,
	joe@perches.com
To: lars@metafoo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965204Ab3DPUhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:37:52 -0400
In-Reply-To: <516DB4B1.9050602@metafoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lars-Peter Clausen <lars@metafoo.de>
Date: Tue, 16 Apr 2013 22:29:37 +0200

> On 04/16/2013 09:28 PM, Fabio Estevam wrote:
>> SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so there is no
>> need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cases.
>> 
>> Remove the unneeded definitions.
>> 
>> Cc: Lars-Peter Clausen <lars@metafoo.de>
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> 
> yea, but now you have the dev_pm_ops struct, even if pm is disabled.

That's fine, it allows the functions to be compile tested in all
configurations.
