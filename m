From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 1/3] xen-netback: make feature-rx-notify mandatory
Date: Thu, 23 Oct 2014 12:16:29 +0100
Message-ID: <20141023111629.GE9188@zion.uk.xensource.com>
References: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com>
 <1413983335-8307-2-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:47650 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbaJWLQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 07:16:30 -0400
Content-Disposition: inline
In-Reply-To: <1413983335-8307-2-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 02:08:53PM +0100, David Vrabel wrote:
> Frontends that do not provide feature-rx-notify may stall because
> netback depends on the notification from frontend to wake the guest Rx
> thread (even if can_queue is false).
> 
> This could be fixed but feature-rx-notify was introduced in 2006 and I
> am not aware of any frontends that do not implement this.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
