From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: rework recvmsg handler msg_name and msg_namelen logic
Date: Thu, 21 Nov 2013 02:07:29 +0100
Message-ID: <20131121010729.GB32587@order.stressinduktion.org>
References: <20131121003828.GA32587@order.stressinduktion.org> <1384995760.2164.33.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56025 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481Ab3KUBHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 20:07:31 -0500
Content-Disposition: inline
In-Reply-To: <1384995760.2164.33.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 05:02:40PM -0800, Joe Perches wrote:
> On Thu, 2013-11-21 at 01:38 +0100, Hannes Frederic Sowa wrote:
> > This patch now always passes msg->msg_namelen as 0. recvmsg handlers must
> > set msg_namelen to the proper size <= sizeof(struct sockaddr_storage)
> > to return msg_name to the user.
> []
> > This change does not alter the user visible error logic as we ignore
> > msg_namelen as long as msg_name is NULL.
> > 
> > Also remove two unnecessary curly brackets in ___sys_recvmsg and change
> > comments to netdev style.
> 
> Perhaps take the opportunity to remove the unnecessary casts of
> struct msghdr.msg_name as it's a void *.
> 
> And there's one other oddity about setting a known NULL to NULL.
> 
> Maybe fix in a follow-on patch?

No, that is easily done in this one. I'll send a v2 shortly.

Thanks!
