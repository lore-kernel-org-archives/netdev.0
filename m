From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [PATCH net-next V2 01/10] net/flower: Introduce hardware offload
 support
Date: Thu, 3 Mar 2016 21:53:35 +0200
Message-ID: <20160303195335.GB15037@office.Home>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
 <1457016960-27832-2-git-send-email-amir@vadai.me>
 <20160303.123033.1239966579179656570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	jiri@mellanox.com, ogerlitz@mellanox.com, saeedm@mellanox.com,
	hadarh@mellanox.com, ronye@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36640 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbcCCTtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 14:49:24 -0500
Received: by mail-wm0-f68.google.com with SMTP id l68so631027wml.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 11:49:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160303.123033.1239966579179656570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 12:30:33PM -0500, David Miller wrote:
> From: Amir Vadai <amir@vadai.me>
> Date: Thu,  3 Mar 2016 16:55:51 +0200
> 
> > @@ -454,11 +501,13 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
> >  		     u32 handle, struct nlattr **tca,
> >  		     unsigned long *arg, bool ovr)
> >  {
> > +	struct net_device *dev = tp->q->dev_queue->dev;
> >  	struct cls_fl_head *head = rtnl_dereference(tp->root);
> 
> This variable is not used.
> 
> And the compiler warns about this, and because of this I am pretty sure you
> aren't looking at the compiler output while testing your builds which is a
> big no-no.
My bad. I did a last minute change that left this variable and somehow
missed the warning (though I did compile and test it).
Will fix for v3
