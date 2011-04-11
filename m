From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] ethtool: prevent null pointer
 dereference with NTUPLE set but no set_rx_ntuple
Date: Mon, 11 Apr 2011 13:21:13 -0700 (PDT)
Message-ID: <20110411.132113.179926013.davem@davemloft.net>
References: <20110408220410.25468.49130.stgit@gitlad.jf.intel.com>
	<20110408220722.25468.98089.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754239Ab1DKUVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:21:49 -0400
In-Reply-To: <20110408220722.25468.98089.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 08 Apr 2011 15:07:22 -0700

> This change is meant to prevent a possible null pointer dereference if
> NETIF_F_NTUPLE is defined but the set_rx_ntuple function pointer is not.
> 
> The main motivation behind this patch is to eventually replace the ntuple
> interfaces entirely with the network flow classifier interfaces.  This
> allows the device drivers to maintain the ntuple check internally while
> using the network flow classifier interface for setting up and displaying
> rules.
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
