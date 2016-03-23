From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH] net: Fix typos and whitespace.
Date: Wed, 23 Mar 2016 08:55:35 -0500
Message-ID: <20160323135535.GA18845@localhost>
References: <20160323134530.18742.35082.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:49663 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755326AbcCWNzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 09:55:44 -0400
Content-Disposition: inline
In-Reply-To: <20160323134530.18742.35082.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+cc Vlad]

On Wed, Mar 23, 2016 at 08:45:30AM -0500, Bjorn Helgaas wrote:
> Fix typos.  Capitalize CPU, NAPI, RCU consistently.  Align structure
> indentation.  No functional change intended; only comment and whitespace
> changes.
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  include/linux/netdevice.h |  215 ++++++++++++++++++++++-----------------------

> @@ -920,7 +920,7 @@ struct tc_to_netdev {
>   *
>   *      Enable or disable the VF ability to query its RSS Redirection Table and
>   *      Hash Key. This is needed since on some devices VF share this information
> - *      with PF and querying it may adduce a theoretical security risk.
> + *      with PF and querying it may introduce a theoretical security risk.
>   * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting)

Most of these are obvious typo fixes, but I want to point out this one
in particular because "adduce" is a real word.  It's possible that's
what Vlad intended in 01a3d796813d ("if_link: Add an additional
parameter to ifla_vf_info for RSS querying"), though it doesn't quite
seem to fit.  Vlad, if you did intend "adduce", my apologies in
advance.

Bjorn
