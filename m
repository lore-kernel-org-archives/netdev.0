From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 2/2] netlink: kill eff_cap from struct netlink_skb_parms
Date: Thu, 3 Mar 2011 12:17:26 -0800
Message-ID: <20110303201726.GU4988@sequoia.sous-sol.org>
References: <4D6F6180.5030903@trash.net>
 <20110303173230.GP4988@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, NetDev <netdev@vger.kernel.org>,
	dm-devel@redhat.com, "David S. Miller" <davem@davemloft.net>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, drbd-dev@lists.linbit.com
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:45480 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752372Ab1CCURq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 15:17:46 -0500
Content-Disposition: inline
In-Reply-To: <20110303173230.GP4988@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Chris Wright (chrisw@sous-sol.org) wrote:
> Ideally, we'd consolidate those into a variant of security_netlink_recv().
> However the issue is with types.  Inside connector callback we only have
> netlink_skb_params (seems inapproriate to cast back out to skb).
> 
> We could change the lsm hook to only pass nsp, but SELinux actually
> cares about the netlink type.  Any ideas?

Actually I misremembered, it only cares on the send path.

We could completely drop skb from recv lsm hook, will send an RFC
momentarily with example.

thanks,
-chris
