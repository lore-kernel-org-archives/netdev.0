From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/15] 6lowpan:
 lowpan_is_iid_16_bit_compressable() does not detect compressable address
 correctly
Date: Tue, 23 Oct 2012 02:49:45 -0400 (EDT)
Message-ID: <20121023.024945.1428104116658345802.davem@davemloft.net>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
	<1350965397-12384-2-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	alan@signal11.us, alex.bluesman.smirnov@gmail.com
To: tony.cheneau@amnesiak.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab2JWGtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:49:47 -0400
In-Reply-To: <1350965397-12384-2-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Cheneau <tony.cheneau@amnesiak.org>
Date: Tue, 23 Oct 2012 00:09:43 -0400

> The current test is not RFC6282 compliant. The same issue has been found
> out and fixed in Contiki. This patch is basicaly a port of their fix.
> 
> Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>

It's really demoralizing to sit down to read a large 15 entry
patch series and this is the first thing I see:

>  /*
> - * check whether we can compress the IID to 16 bits,
> - * it's possible for unicast adresses with first 49 bits are zero only.
> - */
> +* check whether we can compress the IID to 16 bits,
> +* it's possible for unicast adresses with first 49 bits are zero only.
> +*/

Don't break the comment indentation, it was perfectly fine.

I'm not reviewing the rest of the series, you'll need to repost
the entire thing after you fix this.

And if you're smart you'll make sure there aren't similar coding
style issues in the rest of your patches, else it's going to take
a long time to merge this crap into the tree.
