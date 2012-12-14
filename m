From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: do not check x->km.state
Date: Fri, 14 Dec 2012 12:45:45 +0100
Message-ID: <20121214114545.GI18940@secunet.com>
References: <1355389560-7705-1-git-send-email-roy.qing.li@gmail.com>
 <20121213101948.GG18940@secunet.com>
 <20121213.141922.2249665409902614569.davem@davemloft.net>
 <CAJFZqHxZDAeZxLyxddtxCB6ucU6hMxH1TtWcMD2TZGRRA52-_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52862 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319Ab2LNLps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 06:45:48 -0500
Content-Disposition: inline
In-Reply-To: <CAJFZqHxZDAeZxLyxddtxCB6ucU6hMxH1TtWcMD2TZGRRA52-_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 03:02:32PM +0800, RongQing Li wrote:
> 
> since xfrm_output_one() calls xfrm_state_check_expire() too, but without
> checking (x->km.state != XFRM_STATE_VALID), I think we can not directly
> remove the check of km.state from xfrm_state_check_expire(). I have two
> option, which one do you think it is better?
> 
> 1. remove this check in xfrm_state_check_expire, and add a check in
> xfrm_output_one
> 

I think the first option ist the better one. It removes a superfluous
check and we get some more statistics.
