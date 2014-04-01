From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v3 net] xen-netback: disable rogue vif in kthread context
Date: Tue, 1 Apr 2014 12:44:28 +0100
Message-ID: <20140401114428.GA6382@zion.uk.xensource.com>
References: <1396352037-7721-1-git-send-email-wei.liu2@citrix.com>
 <533AA4D4.10709@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, <zoltan.kiss@citrix.com>,
	<edwin@etorok.net>, Ian Campbell <ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:21602 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbaDALo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 07:44:29 -0400
Content-Disposition: inline
In-Reply-To: <533AA4D4.10709@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2014 at 12:36:52PM +0100, David Vrabel wrote:
> On 01/04/14 12:33, Wei Liu wrote:
> > @@ -1574,6 +1575,16 @@ int xenvif_kthread(void *data)
> >  		wait_event_interruptible(vif->wq,
> >  					 rx_work_todo(vif) ||
> >  					 kthread_should_stop());
> 
> I think you're still missing a || vif->disabled from this wait_event
> conditional.
> 

Good catch. I will resubmit.

Wei.

> David
