From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 2/2] SELinux: Add network ingress and egress
 control permission checks
Date: Mon, 07 Jan 2008 22:02:11 -0800 (PST)
Message-ID: <20080107.220211.250933730.davem@davemloft.net>
References: <20080107173829.13488.47471.stgit@flek.americas.hpqcorp.net>
	<20080107174748.13488.11389.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35687
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750970AbYAHGCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:02:12 -0500
In-Reply-To: <20080107174748.13488.11389.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Mon, 07 Jan 2008 12:47:48 -0500

> This patch implements packet ingress/egress controls for SELinux which allow
> SELinux security policy to control the flow of all IPv4 and IPv6 packets into
> and out of the system.  Currently SELinux does not have proper control over
> forwarded packets and this patch corrects this problem.
> 
> Special thanks to Venkat Yekkirala <vyekkirala@trustedcs.com> whose earlier
> work on this topic eventually led to this patch.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

This looks fine, and since it doesn't touch anything under net/
please feel free to merge it however you like.
