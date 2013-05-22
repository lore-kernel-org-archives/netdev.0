From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 2/2] xen-netfront: split event channels
 feature support
Date: Wed, 22 May 2013 16:52:38 +0100
Message-ID: <519CE9C6.3010907@citrix.com>
References: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com> <1369090931-27306-3-git-send-email-wei.liu2@citrix.com> <519B78F5.5020301@citrix.com> <20130521134149.GN32007@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:9386 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752633Ab3EVPwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 11:52:40 -0400
In-Reply-To: <20130521134149.GN32007@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/05/13 14:41, Wei Liu wrote:
> On Tue, May 21, 2013 at 02:39:01PM +0100, David Vrabel wrote:
> [...]
>>> +	info->rx_evtchn = info->tx_evtchn;
>>> +	info->rx_irq = info->tx_irq = err;
>>> +	dev_info(&info->xbdev->dev,
>>> +		 "single event channel, evtchn = %d, irq = %d\n",
>>> +		 info->tx_evtchn, info->tx_irq);
>>
>> This message is pointless chatter as the information is available
>> elsewhere.  Please remove.
>>
> 
> Do you mean /proc/interrupt by "elsewhere"? Information there doesn't
> give you irq<->evtchn mapping info.

A combination of /proc/interrupts and the xenstore keys.

David
