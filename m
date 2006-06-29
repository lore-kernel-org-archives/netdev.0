From: CaT <cat@zip.com.au>
Subject: Re: 2.6.17.1: fails to fully get webpage
Date: Thu, 29 Jun 2006 13:09:23 +1000
Message-ID: <20060629030923.GI2149@zip.com.au>
References: <20060629015915.GH2149@zip.com.au> <20060628.194627.74748190.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nessie.weebeastie.net ([220.233.7.36]:51727 "EHLO
	bunyip.lochness.weebeastie.net") by vger.kernel.org with ESMTP
	id S1751351AbWF2DIP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 23:08:15 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060628.194627.74748190.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 28, 2006 at 07:46:27PM -0700, David Miller wrote:
> From: CaT <cat@zip.com.au>
> Date: Thu, 29 Jun 2006 11:59:15 +1000
> 
> > Now I found a thread about tcp window scaling affecting the loading of
> > some sites but I fail to load the above site with
> > /proc/sys/net/ipv4/tcp_adv_win_scale set to 6 and 2 under 2.6.17.1
> > whilst it works just fine with the /proc entry set to either 7, 6 or 2
> > under 2.6.16.18.
> 
> You must have misread those threads.  To work around the problem,
> you don't modify tcp_adv_win_scale, instead what you do is set
> tcp_window_scaling to 0.

Yup. Must've. Just tried it now and setting tcp_window_scaling to 0
makes the site load. Sorry about that. Looks like I'll have to remember
to make sure that gets set to zero on any servers I wind up having to
upgrade to 2.6.17 and beyond.

Bugger. :/

-- 
    "To the extent that we overreact, we proffer the terrorists the
    greatest tribute."
    	- High Court Judge Michael Kirby
