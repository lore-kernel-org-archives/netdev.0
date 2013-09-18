From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v4] Don't destroy the netdev until the vif is
 shut down
Date: Wed, 18 Sep 2013 11:37:04 +0100
Message-ID: <20130918103704.GA511@zion.uk.xensource.com>
References: <1379436368-6882-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:18392 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551Ab3IRKhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 06:37:07 -0400
Content-Disposition: inline
In-Reply-To: <1379436368-6882-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 05:46:08PM +0100, Paul Durrant wrote:
> Without this patch, if a frontend cycles through states Closing
> and Closed (which Windows frontends need to do) then the netdev
> will be destroyed and requires re-invocation of hotplug scripts
> to restore state before the frontend can move to Connected. Thus
> when udev is not in use the backend gets stuck in InitWait.
> 
> With this patch, the netdev is left alone whilst the backend is
> still online and is only de-registered and freed just prior to
> destroying the vif (which is also nicely symmetrical with the
> netdev allocation and registration being done during probe) so
> no re-invocation of hotplug scripts is required.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks!
Wei.
