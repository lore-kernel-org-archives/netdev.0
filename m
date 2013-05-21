From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 2/2] xen-netfront: split event
 channels feature support
Date: Tue, 21 May 2013 14:41:49 +0100
Message-ID: <20130521134149.GN32007@zion.uk.xensource.com>
References: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com>
 <1369090931-27306-3-git-send-email-wei.liu2@citrix.com>
 <519B78F5.5020301@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<konrad.wilk@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:15388 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681Ab3EUNl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 09:41:57 -0400
Content-Disposition: inline
In-Reply-To: <519B78F5.5020301@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 02:39:01PM +0100, David Vrabel wrote:
[...]
> > +	info->rx_evtchn = info->tx_evtchn;
> > +	info->rx_irq = info->tx_irq = err;
> > +	dev_info(&info->xbdev->dev,
> > +		 "single event channel, evtchn = %d, irq = %d\n",
> > +		 info->tx_evtchn, info->tx_irq);
> 
> This message is pointless chatter as the information is available
> elsewhere.  Please remove.
> 

Do you mean /proc/interrupt by "elsewhere"? Information there doesn't
give you irq<->evtchn mapping info.


Wei.
