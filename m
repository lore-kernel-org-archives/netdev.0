From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: re-ignore EADDRINUSE from igmp_join
Date: Tue, 25 Aug 2015 16:25:05 -0700 (PDT)
Message-ID: <20150825.162505.907160908950866974.davem@davemloft.net>
References: <55DCB958.3080904@gmail.com>
	<78f32de72ff150f6a1260f44a409cfed915a17e1.1440544648.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lists@jnielsen.net
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbHYXZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:25:07 -0400
In-Reply-To: <78f32de72ff150f6a1260f44a409cfed915a17e1.1440544648.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue, 25 Aug 2015 20:22:35 -0300

> Before 56ef9c909b40[1] it used to ignore all errors from igmp_join().
> That commit enhanced that and made it error out whatever error happened
> with igmp_join(), but that's not good because when using multicast
> groups vxlan will try to join it multiple times if the socket is reused
> and then the 2nd and further attempts will fail with EADDRINUSE.
> 
> As we don't track to which groups the socket is already subscribed, it's
> okay to just ignore that error.
> 
> Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
> Reported-by: John Nielsen <lists@jnielsen.net>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> 
> John, please see how this goes for you. It worked in here.
> 
> Dave, please consider this for stable trees. At least 4.1 is affected.

Applied and queued up for -stable, thanks.
