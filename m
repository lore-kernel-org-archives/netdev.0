From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] netlabel: correctly list all the static label mappings
Date: Thu, 07 Mar 2013 16:26:28 -0500
Message-ID: <1523551.DoMpm8OhCt@sifl>
References: <20130306214524.4965.59796.stgit@localhost> <20130307.162119.846409617201380362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932876Ab3CGV0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 16:26:30 -0500
In-Reply-To: <20130307.162119.846409617201380362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, March 07, 2013 04:21:19 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Wed, 06 Mar 2013 16:45:24 -0500
> 
> > When we have a large number of static label mappings that spill across
> > the netlink message boundary we fail to properly save our state in the
> > netlink_callback struct which causes us to repeat the same listings.
> > This patch fixes this problem by saving the state correctly between
> > calls to the NetLabel static label netlink "dumpit" routines.
> > 
> > Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> Applied and queued up for -stable, thanks.
> 
> > Cc: stable@vger.kernel.org
> 
> Please just ask me to queue up networking fixes for stable, rather
> than CC:'ing it to stable.

No problem, I'll do that in the future.

Thanks.

-- 
paul moore
security and virtualization @ redhat
