From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 1/1] r8169: fix offloaded tx checksum for small
 packets.
Date: Mon, 20 May 2013 00:01:49 -0700 (PDT)
Message-ID: <20130520.000149.840626794135761237.davem@davemloft.net>
References: <20130518112446.GA21268@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com,
	stefan.bader@canonical.com, holger.hoffstaette@googlemail.com,
	sergei.shtylyov@cogentembedded.com, ben@decadent.org.uk
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab3ETHBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 03:01:50 -0400
In-Reply-To: <20130518112446.GA21268@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 18 May 2013 13:24:46 +0200

> 8168evl offloaded checksums are wrong since commit
> e5195c1f31f399289347e043d6abf3ffa80f0005 ("r8169: fix 8168evl frame padding.")
> pads small packets to 60 bytes (without ethernet checksum). Typical symptoms
> appear as UDP checksums which are wrong by the count of added bytes.
> 
> It isn't worth compensating. Let the driver checksum.
> 
> Due to the skb length changes, TSO code is moved before the Tx descriptor gets
> written.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
> 
>  I reworked some code since v1 to avoid wtf effects in the future. Holger's
>  Tested-by is thus not included. While I trust my testing, it would be nice
>  to wait for his ack as well.
> 
>  This is obviously stuff for -stable.

Applied and queued up for -stable, thanks!
