From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NET: DCB generic netlink interface
Date: Wed, 11 Jun 2008 23:28:44 +0200
Message-ID: <20080611212844.GT20815@postel.suug.ch>
References: <20080605.074324.38999631.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com> <20080611175156.GR20815@postel.suug.ch> <48501083.2040006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43899 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbYFKV2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 17:28:23 -0400
Content-Disposition: inline
In-Reply-To: <48501083.2040006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net> 2008-06-11 19:50
> Thomas Graf wrote:
> >Another area of interest is sending congestion frames on our own. We
> >could finally implement real ingress software shaping and turn every
> >linux system into a DCB capable node.
> 
> There was a qdisc submission for a scheduler called "pace" (IIRC)
> that did this. It needed some cleanups before merging, but nothing
> grave.

Do you know if it used congestion notifcation on link level? I can't
seem to find the posting.
