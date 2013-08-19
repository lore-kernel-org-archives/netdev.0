From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [ PATCH net-next ] xfrm: remove irrelevant comment in
 xfrm_input().
Date: Mon, 19 Aug 2013 13:47:00 +0200
Message-ID: <20130819114700.GY26773@secunet.com>
References: <1376916431-8249-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44139 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286Ab3HSLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 07:47:03 -0400
Content-Disposition: inline
In-Reply-To: <1376916431-8249-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 19, 2013 at 03:47:11PM +0300, Rami Rosen wrote:
> This patch removes a comment in xfrm_input() which became irrelevant
> due to commit 2774c13, "xfrm: Handle blackhole route creation via afinfo".
> That commit removed returning -EREMOTE in the xfrm_lookup() method when the 
> packet should be discarded  and also removed the correspoinding -EREMOTE 
> handlers. This was replaced by calling the make_blackhole() method. Therefore
> the comment about -EREMOTE is not relevant anymore.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied to ipsec-next, thanks!
