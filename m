From: Lars-Peter Clausen <lars@metafoo.de>
Subject: Re: [PATCH 5/5] ks8851: Remove unneeded PM_OPS definitions
Date: Wed, 17 Apr 2013 08:27:55 +0200
Message-ID: <516E40EB.5080505@metafoo.de>
References: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>	<1366140511-3836-5-git-send-email-fabio.estevam@freescale.com>	<516DB4B1.9050602@metafoo.de> <20130416.163750.1652843849557504513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, netdev@vger.kernel.org,
	joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost.informatik.uni-hamburg.de ([134.100.9.70]:44732 "EHLO
	mailhost.informatik.uni-hamburg.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965746Ab3DQGZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 02:25:29 -0400
In-Reply-To: <20130416.163750.1652843849557504513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2013 10:37 PM, David Miller wrote:
> From: Lars-Peter Clausen <lars@metafoo.de>
> Date: Tue, 16 Apr 2013 22:29:37 +0200
> 
>> On 04/16/2013 09:28 PM, Fabio Estevam wrote:
>>> SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so there is no
>>> need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cases.
>>>
>>> Remove the unneeded definitions.
>>>
>>> Cc: Lars-Peter Clausen <lars@metafoo.de>
>>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
>>
>> yea, but now you have the dev_pm_ops struct, even if pm is disabled.
> 
> That's fine, it allows the functions to be compile tested in all
> configurations.

The functions are still protected by a #ifdef, it's just the dev_pm_ops struct
which is not anymore.

- Lars
