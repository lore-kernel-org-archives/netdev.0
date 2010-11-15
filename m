From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] net: consolidate 8021q tagging
Date: Mon, 15 Nov 2010 10:12:10 -0800 (PST)
Message-ID: <20101115.101210.179934630.davem@davemloft.net>
References: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
	<20101031002242.8691.38060.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46388
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755364Ab0KOSLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 13:11:45 -0500
In-Reply-To: <20101031002242.8691.38060.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Sat, 30 Oct 2010 17:22:42 -0700

> Now that VLAN packets are tagged in dev_hard_start_xmit()
> at the bottom of the stack we no longer need to tag them
> in the 8021Q module (Except in the !VLAN_FLAG_REORDER_HDR
> case).
> 
> This allows the accel path and non accel paths to be consolidated.
> Here the vlan_tci in the skb is always set and we allow the
> stack to add the actual tag in dev_hard_start_xmit().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
