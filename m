From: Simon Horman <horms@verge.net.au>
Subject: Re: IPVS: use proper timeout instead of fixed value
Date: Mon, 29 Oct 2007 17:59:23 +0900
Message-ID: <20071029085921.GB30256@verge.net.au>
References: <20071029070555.78D694FA13@tabatha.lab.ultramonkey.org> <20071029.013515.07385320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lvs-devel@linuxvirtualserver.org,
	wensong@linux-vs.org, ja@ssi.bg, jmack@wm7d.net,
	graeme@graemef.net, lvs@rsv.se, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:58461 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170AbXJ2I70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 04:59:26 -0400
Content-Disposition: inline
In-Reply-To: <20071029.013515.07385320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 01:35:15AM -0700, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Mon, 29 Oct 2007 16:05:55 +0900 (JST)
> 
> > From: Andy Gospodarek <andy@greyhouse.net>
> > 
> > Instead of using the default timeout of 3 minutes, this uses the timeout
> > specific to the protocol used for the connection. The 3 minute timeout
> > seems somewhat arbitrary (though I know it is used other places in the
> > ipvs code) and when failing over it would be much nicer to use one of
> > the configured timeout values.
> > 
> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> > Acked-by: Simon Horman <horms@verge.net.au>
> 
> I would apply this but it does not apply to current 2.6.x,
> please resubmit.

I tried against net-2.6 and it seemed to work.
Was I mistaken or should I be using a different tree?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

