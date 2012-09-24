From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next] gianfar: Change default HW Tx queue scheduling
 mode
Date: Mon, 24 Sep 2012 13:46:43 +0300
Message-ID: <50603A13.3030709@freescale.com>
References: <1348156674-31551-1-git-send-email-claudiu.manoil@freescale.com> <20120921.133528.2219558580262606729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:22937
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398Ab2IXKqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 06:46:55 -0400
In-Reply-To: <20120921.133528.2219558580262606729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2012 08:35 PM, David Miller wrote:
> From: Claudiu Manoil <claudiu.manoil@freescale.com>
> Date: Thu, 20 Sep 2012 18:57:54 +0300
>
>> The TXSCHED setting may be changed at runtime, via sysfs, for devices
>> using multiple H/W Tx queues. For single queue devices this config
>> option is disabled, as the TXSCHED setting is superfluous in those cases.
>
> Please, no special driver specific sysfs knobs.
>
> Extend ethtool as necessary for your needs, so that any driver can
> provide this kind of configurability in a consistent way for users..
>
Ok.
Resent the patch addressing the watchdog timeout issue, without the 
runtime configuration part.
(see http://patchwork.ozlabs.org/patch/186315/).
This config option seems to be better off in a separate patch, 
especially if it would imply changes to ethtool.
What would you think of such an ethtool extension? Beside allowing the 
user to choose b/w letting the H/W to service its Tx queues equally or 
according to a built-in priority scheme, it could also provide api to 
configure scheduling weights per Tx queue for a weighted round-robin 
queue selection scheme, or, to configure only a single weight for all 
the queues (for a balanced scheme). (Are there currently other drivers/ 
devices that would use such an option?)

Thanks,
Claudiu
