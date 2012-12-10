From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/7] bna: Code Cleanup and Enhancements
Date: Mon, 10 Dec 2012 17:13:49 -0500 (EST)
Message-ID: <20121210.171349.1368932708858713762.davem@davemloft.net>
References: <1355175725-19202-1-git-send-email-rmody@brocade.com>
	<1355175725-19202-2-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	David.Laight@ACULAB.COM, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab2LJWN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 17:13:56 -0500
In-Reply-To: <1355175725-19202-2-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Mon, 10 Dec 2012 13:41:59 -0800

> -		skb = unmap_array[unmap_cons].skb;
> -		BUG_ON(!(skb));
> -		unmap_array[unmap_cons].skb = NULL;
> +		curr_ua = &unmap_array[unmap_cons];
> +
> +		skb = curr_ua->skb;
> +		BUG_ON(!(skb));\
                               ^^^

Really?

Please carefully review your own work before submitting it for
inclusion.  When you have erroneous things like this in the
very first patch it reflects very poorly upon the quality of
your work.
