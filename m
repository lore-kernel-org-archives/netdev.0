From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [CCID-3]: Remove ccid3hc{tx,rx}_ prefixes
Date: Tue, 27 May 2008 06:26:12 -0700 (PDT)
Message-ID: <20080527.062612.59188315.davem@davemloft.net>
References: <1211877167-10995-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-3-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-4-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757137AbYE0N0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 09:26:16 -0400
In-Reply-To: <1211877167-10995-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:43 +0100

> This patch does the same for CCID-3 as the previous patch for CCID-2:
> 
>         s#ccid3hctx_##g;
>         s#ccid3hcrx_##g;
> 
> plus manual editing to retain consistency.
> 
> Please note: expanded the fields of the `struct tfrc_tx_info' in the hc_tx_sock,
> since using short #define identifiers is not a good idea. The only place where
> this embedded struct was used is ccid3_hc_tx_getsockopt().
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

My same comments for CCID-2 apply here, don't do this, we use
the member name prefixes to make the code easier to search
precisely.
