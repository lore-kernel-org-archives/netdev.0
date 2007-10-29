From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: IPVS: use proper timeout instead of fixed value
Date: Mon, 29 Oct 2007 08:50:01 -0400
Message-ID: <20071029125000.GA5889@gospo.rdu.redhat.com>
References: <20071029070555.78D694FA13@tabatha.lab.ultramonkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lvs-devel@linuxvirtualserver.org,
	wensong@linux-vs.org, ja@ssi.bg, Joseph Mack NA3T <jmack@wm7d.net>,
	Graeme Fowler <graeme@graemef.net>,
	Andreas Lundqvist <lvs@rsv.se>,
	Andy Gospodarek <andy@greyhouse.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbXJ2Mwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 08:52:49 -0400
Content-Disposition: inline
In-Reply-To: <20071029070555.78D694FA13@tabatha.lab.ultramonkey.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 04:05:55PM +0900, Simon Horman wrote:
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
> 

Thanks for re-visiting this, Simon!  It's too bad that the other work
never got done, but I'm glad to see this will get included.

