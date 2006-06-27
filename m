From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] netlink: encapsulate eff_cap usage within security
 framework
Date: Tue, 27 Jun 2006 13:26:30 -0700 (PDT)
Message-ID: <20060627.132630.07456167.davem@davemloft.net>
References: <1151342346.5264.45.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dgoeddel@trustedcs.com,
	chrisw@sous-sol.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3281
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161280AbWF0U0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:26:32 -0400
To: sds@tycho.nsa.gov
In-Reply-To: <1151342346.5264.45.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Smalley <sds@tycho.nsa.gov>
Date: Mon, 26 Jun 2006 13:19:05 -0400

> This patch encapsulates the usage of eff_cap (in netlink_skb_params) within
> the security framework by extending security_netlink_recv to include a required
> capability parameter and converting all direct usage of eff_caps outside
> of the lsm modules to use the interface.  It also updates the SELinux
> implementation of the security_netlink_send and security_netlink_recv
> hooks to take advantage of the sid in the netlink_skb_params struct.
> This also enables SELinux to perform auditing of netlink capability checks.
> Please apply, for 2.6.18 if possible.
> 
> Signed-off-by: Darrel Goeddel <dgoeddel@trustedcs.com>
> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> Acked-by:  James Morris <jmorris@namei.org>

Applied, thanks a lot.
