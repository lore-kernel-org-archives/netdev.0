From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/21] udp: call dst_hold_safe() in
 udp_sk_rx_set_dst()
Date: Fri, 16 Jun 2017 15:02:46 -0400 (EDT)
Message-ID: <20170616.150246.2299597096137479184.davem@davemloft.net>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
        <20170616174744.139688-3-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com,
        weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752059AbdFPTCy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 15:02:54 -0400
In-Reply-To: <20170616174744.139688-3-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Fri, 16 Jun 2017 10:47:25 -0700

> +	if (dst)
> +		/* set noref for now.
> +		 * any place which wants to hold dst has to call
> +		 * dst_hold_safe()
> +		 */
> +		skb_dst_set_noref(skb, dst);

You must enclose the code in curly braces if you want to put a comment
in this one-line basic block of the 'if' statement.

Otherwise it's hard to read.

Likewise for the other similar change in this file.

THanks.
