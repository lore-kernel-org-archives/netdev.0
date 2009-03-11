From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
 non-drops and modifying end-of-line points for skbs
Date: Wed, 11 Mar 2009 09:18:30 -0700 (PDT)
Message-ID: <20090311.091830.152269823.davem@davemloft.net>
References: <20090303170307.GD1480@hmsreliant.think-freely.org>
	<20090305210105.GC12835@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48405
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750870AbZCKQSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 12:18:44 -0400
In-Reply-To: <20090305210105.GC12835@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 5 Mar 2009 16:01:05 -0500

> Ok, as requested, new version of this patch to add in bifurcation of kfree_skb
> into two versions, one for legitimate kfree's, and one for drops
> 
> Modification Notes:
> 1) Renamed kfree_skb_clean to consume_skb, to better identify points where we
> are finished with an skb
> 
> 2) checkpatch cleanups

Looks good.

Respin everything with the requested changes I asked for in #4
and I can likely toss this into net-next-2.6, thanks!
