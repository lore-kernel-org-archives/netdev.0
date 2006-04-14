From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] atm: clip causes unregister hang
Date: Fri, 14 Apr 2006 15:07:38 -0700 (PDT)
Message-ID: <20060414.150738.69057483.davem@davemloft.net>
References: <20060412131527.71f42d58@localhost.localdomain>
	<20060412202551.GA20085@gondor.apana.org.au>
	<20060412145254.4dd21be6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43178
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030202AbWDNWHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:07:32 -0400
To: shemminger@osdl.org
In-Reply-To: <20060412145254.4dd21be6@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 12 Apr 2006 14:52:54 -0700

> If Classical IP over ATM module is loaded, its neighbor table gets
> populated when permanent neighbor entries are created; but these entries
> are not flushed when the device is removed. Since the entry never gets
> flushed the unregister of the network device never completes.
> 
> This version of the patch also adds locking around the reference to
> the atm arp daemon to avoid races with events and daemon state changes.
> (Note: barrier() was never really safe)
> 
> Bug-reference: http://bugzilla.kernel.org/show_bug.cgi?id=6295
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
