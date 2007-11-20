From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] ipvs: Flag synced connections and expose them in
 proc
Date: Mon, 19 Nov 2007 21:52:55 -0800 (PST)
Message-ID: <20071119.215255.33380832.davem@davemloft.net>
References: <20071114182439.821730508@natsuko.shinjuku.tokyo.vergenet.net>
	<20071114182717.864165392@natsuko.shinjuku.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg,
	jmack@wm7d.net, graeme@graemef.net, rumen@voicecho.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58565
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751548AbXKTFw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:52:56 -0500
In-Reply-To: <20071114182717.864165392@natsuko.shinjuku.tokyo.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Nov 2007 10:24:40 -0800

> From: Rumen Bogdanovski <rumen@voicecho.com>
> 
> This patch labels the sync-created connections with IP_VS_CONN_F_SYNC
> flag and creates /proc/net/ip_vs_conn_sync to enable monitoring of the
> origin of the connections, if they are local or created by the 
> synchronization.
> 
> Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied to net-2.6.25
