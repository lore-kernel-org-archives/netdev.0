From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.17.1: fails to fully get webpage
Date: Wed, 28 Jun 2006 19:46:27 -0700 (PDT)
Message-ID: <20060628.194627.74748190.davem@davemloft.net>
References: <20060629015915.GH2149@zip.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46492
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751472AbWF2Cq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 22:46:29 -0400
To: cat@zip.com.au
In-Reply-To: <20060629015915.GH2149@zip.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: CaT <cat@zip.com.au>
Date: Thu, 29 Jun 2006 11:59:15 +1000

> Now I found a thread about tcp window scaling affecting the loading of
> some sites but I fail to load the above site with
> /proc/sys/net/ipv4/tcp_adv_win_scale set to 6 and 2 under 2.6.17.1
> whilst it works just fine with the /proc entry set to either 7, 6 or 2
> under 2.6.16.18.

You must have misread those threads.  To work around the problem,
you don't modify tcp_adv_win_scale, instead what you do is set
tcp_window_scaling to 0.
