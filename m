From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/3] [PATCHSET] netlink error management
Date: Thu, 22 Mar 2007 20:57:54 +0100
Message-ID: <20070322195754.GZ521@postel.suug.ch>
References: <20070321231801.342849239@lsx.localdomain> <20070322.122355.48516149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55540 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934210AbXCVT5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 15:57:34 -0400
Content-Disposition: inline
In-Reply-To: <20070322.122355.48516149.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2007-03-22 12:23
> From: Thomas Graf <tgraf@suug.ch>
> Date: Thu, 22 Mar 2007 00:18:01 +0100
> 
> > This series of patches simplifies the error management and
> > signalization of dump starts of netlink_run_queue() message
> > handlers. It touches a fair bit of nfnetlink code as the
> > error pointer has been passed on to subsystems.
> 
> Thomas can you respin these patches?  They no longer apply
> now that I put your other rtnl_link bits into net-2.6.22

I guess I've posted too many patches series, the patches should
still apply, at least it works in my quilt tree, but depend on
others. The series I've posted in the correct order are:

[RESEND] rtnetlink message handler registration interface
  already applied
 
[RESEND] [NET] rules: Unified rules dumping
  already applied

[PATCH 0/5] [PATCHSET] Netlink Patches
  even though there have been objects because of nfnetlink
  at first, the patches can go in as-is

[NETFILTER] nfnetlink: netlink_run_queue() already checks
                       for NLM_F_REQUEST

[PATCH 0/3] [PATCHSET] netlink error management
