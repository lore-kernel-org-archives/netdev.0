From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: add send and receive capability requirement
 and capability flags
Date: Mon, 28 Jan 2013 22:55:24 -0500 (EST)
Message-ID: <20130128.225524.472002600658532532.davem@davemloft.net>
References: <1358952744-29288-1-git-send-email-rbriggs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rgb@redhat.com
To: rbriggs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab3A2DzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 22:55:25 -0500
In-Reply-To: <1358952744-29288-1-git-send-email-rbriggs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Guy Briggs <rbriggs@redhat.com>
Date: Wed, 23 Jan 2013 09:52:24 -0500

> From: Richard Guy Briggs <rgb@redhat.com>
> 
> Currently netlink socket permissions are controlled by the
> NL_CFG_F_NONROOT_{RECV,SEND} flags in the kernel socket configuration or by the
> CAP_NET_ADMIN capability of the client.  The former allows non-root users
> access to the socket.  The latter allows all network admin clients access to
> the socket.  It would be useful to be able to further restrict this access to
> send or receive capabilities individually within specific subsystems with a
> more targetted capability.  Two more flags, NL_CFG_F_CAPABILITY_{RECV,SEND},
> have been added to specifically require a named capability should the subsystem
> request it, allowing the client to drop other broad unneeded capabilities.
> 
> Signed-off-by: Richard Guy Briggs <rbriggs@redhat.com>

I've been looking at this over and over again the past few days,
are you really sure you cannot get the behavior you need within
the current framework and using existing facilities?
