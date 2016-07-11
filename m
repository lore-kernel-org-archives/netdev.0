From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next] IPVS Updates for v4.8
Date: Mon, 11 Jul 2016 12:04:24 +0200
Message-ID: <20160711100424.GA6412@salvia>
References: <1467916840-17005-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41776 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030622AbcGKKEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 06:04:34 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 1AAE717AB6A
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 12:04:32 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id F3E07266749
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 12:04:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2C5B1FAB52
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 12:04:29 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1467916840-17005-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 08:40:39PM +0200, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these enhancements to the IPVS. This alters the behaviour
> of the "least connection" schedulers such that pre-established connections
> are included in the active connection count. This avoids overloading
> servers when a large number of new connections arrive in a short space of
> time - e.g. when clients reconnect after a node or network failure.
> 
> 
> The following changes since commit c6ac37d8d8843fb1fdc34e4a2a41a4f027ab670c:
> 
>   netfilter: nf_log: fix error on write NONE to logger choice sysctl (2016-07-05 14:57:57 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.8

Pulled, thanks Simon.
