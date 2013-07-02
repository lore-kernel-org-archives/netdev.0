From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] ipip: fix a regression in ioctl
Date: Tue, 02 Jul 2013 01:13:43 -0700 (PDT)
Message-ID: <20130702.011343.820354785599717014.davem@davemloft.net>
References: <1372747774-28570-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab3GBINo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:13:44 -0400
In-Reply-To: <1372747774-28570-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue,  2 Jul 2013 14:49:34 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> This is a regression introduced by 
> commit fd58156e456d9f68fe0448 (IPIP: Use ip-tunneling code.)
> 
> Similar to GRE tunnel, previously we only check the parameters
> for SIOCADDTUNNEL and SIOCCHGTUNNEL, after that commit, the
> check is moved for all commands.
> 
> So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.
> 
> Also, the check for i_key, o_key etc. is suspicious too,
> which did not exist before, reset them before passing
> to ip_tunnel_ioctl().
> 
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied and queued up for -stable, thanks!
