From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] f_phonet: fix skb truesize underestimation
Date: Tue, 27 Mar 2012 22:51:09 -0400 (EDT)
Message-ID: <20120327.225109.752822925052179338.davem@davemloft.net>
References: <1332853442.3248.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, balbi@ti.com, remi.denis-courmont@nokia.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab2C1CvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:51:19 -0400
In-Reply-To: <1332853442.3248.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Mar 2012 06:04:02 -0700

> Now skb_add_rx_frag() has a truesize parameter, we can fix f_phonet to
> properly account truesize of each fragment : a full page.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
