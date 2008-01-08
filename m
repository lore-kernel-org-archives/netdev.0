From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v2 2/2] SELinux: Add network ingress and egress control permission checks
Date: Tue, 8 Jan 2008 08:13:57 -0500
Message-ID: <200801080813.57719.paul.moore@hp.com>
References: <20080107173829.13488.47471.stgit@flek.americas.hpqcorp.net> <20080107174748.13488.11389.stgit@flek.americas.hpqcorp.net> <20080107.220211.250933730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:31366 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121AbYAHNOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 08:14:11 -0500
In-Reply-To: <20080107.220211.250933730.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 08 January 2008 1:02:11 am David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Mon, 07 Jan 2008 12:47:48 -0500
>
> > This patch implements packet ingress/egress controls for SELinux which
> > allow SELinux security policy to control the flow of all IPv4 and IPv6
> > packets into and out of the system.  Currently SELinux does not have
> > proper control over forwarded packets and this patch corrects this
> > problem.
> >
> > Special thanks to Venkat Yekkirala <vyekkirala@trustedcs.com> whose
> > earlier work on this topic eventually led to this patch.
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
>
> This looks fine, and since it doesn't touch anything under net/
> please feel free to merge it however you like.

Thanks.  For the record, I believe the plan is that James will be pushing all 
the labeled networking changes to Linus when the time comes.

-- 
paul moore
linux security @ hp
