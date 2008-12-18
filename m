From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp_diag: LISTEN sockets don't have CCIDs
Date: Wed, 17 Dec 2008 16:08:19 -0800 (PST)
Message-ID: <20081217.160819.99264095.davem@davemloft.net>
References: <20081217200332.GY14518@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751907AbYLRAIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 19:08:17 -0500
In-Reply-To: <20081217200332.GY14518@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 17 Dec 2008 18:03:32 -0200

> And thus when we try to use 'ss -danemi' on these sockets that have no
> ccid blocks (data collected using systemtap after I fixed the problem):
> 
> dccp_diag_get_info sk=0xffff8801220a3100, dp->dccps_hc_rx_ccid=0x0000000000000000, dp->dccps_hc_tx_ccid=0x0000000000000000
> 
> We get an OOPS:
 ...
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-next-2.6, thanks!
