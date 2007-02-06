From: David Miller <davem@davemloft.net>
Subject: Re: [patch 10/11] dccp-warning-fixes
Date: Mon, 05 Feb 2007 18:18:36 -0800 (PST)
Message-ID: <20070205.181836.56812810.davem@davemloft.net>
References: <200702060032.l160WCkf004646@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@conectiva.com.br
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965461AbXBFCSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:18:37 -0500
In-Reply-To: <200702060032.l160WCkf004646@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:31:09 -0800

> From: Andrew Morton <akpm@osdl.org>
> 
> sparc64:
> 
> net/dccp/ccids/ccid3.c: In function `ccid3_hc_tx_packet_recv':
> net/dccp/ccids/ccid3.c:480: warning: long long unsigned int format, __u64 arg (arg 6)
> net/dccp/ccids/ccid3.c: In function `ccid3_hc_rx_packet_recv':
> net/dccp/ccids/ccid3.c:1007: warning: long int format, different type arg (arg 3)
> net/dccp/ccids/ccid3.c:1007: warning: long int format, different type arg (arg 4)
> 
> opaque types must be suitably cast for printing.
> 
> Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
