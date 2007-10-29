From: David Miller <davem@davemloft.net>
Subject: Re: IPVS: use proper timeout instead of fixed value
Date: Mon, 29 Oct 2007 01:35:15 -0700 (PDT)
Message-ID: <20071029.013515.07385320.davem@davemloft.net>
References: <20071029070555.78D694FA13@tabatha.lab.ultramonkey.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@linuxvirtualserver.org,
	wensong@linux-vs.org, ja@ssi.bg, jmack@wm7d.net,
	graeme@graemef.net, lvs@rsv.se, andy@greyhouse.net
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45448
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbXJ2IfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 04:35:15 -0400
In-Reply-To: <20071029070555.78D694FA13@tabatha.lab.ultramonkey.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Mon, 29 Oct 2007 16:05:55 +0900 (JST)

> From: Andy Gospodarek <andy@greyhouse.net>
> 
> Instead of using the default timeout of 3 minutes, this uses the timeout
> specific to the protocol used for the connection. The 3 minute timeout
> seems somewhat arbitrary (though I know it is used other places in the
> ipvs code) and when failing over it would be much nicer to use one of
> the configured timeout values.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Acked-by: Simon Horman <horms@verge.net.au>

I would apply this but it does not apply to current 2.6.x,
please resubmit.

Thanks.
