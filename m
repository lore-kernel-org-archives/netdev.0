From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH net-next 0/9] selective (per/namespace) flush of
	rt_cache
Date: Mon, 07 Jul 2008 14:51:09 +0400
Message-ID: <1215427869.29879.81.camel@iris.sw.ru>
References: <1215177360.27873.50.camel@iris.sw.ru>
	 <20080705.205548.122498335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42889 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbYGGKvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:51:07 -0400
In-Reply-To: <20080705.205548.122498335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-07-05 at 20:55 -0700, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Fri, 04 Jul 2008 17:16:00 +0400
> 
> > This series of patches implements selective rt cache flushing to make
> > sure that in one namespace we'll not been able to affect the performance
> > of other from the user space.
> 
> Applied and pushed out to net-next-2.6, thanks.
> 
> Although I wish patch 9 didn't have to be so ugly. :-/ Also, is it
> really the right thing to do if another namespace's RT cache entries
> are in fact chewing up all the slots in a hash chain?  I think
> the replacement garbage collection algorithm should be namespace
> agnostic.

hmmm... it looks like a name rt_is_expired is not good enough for the
case. May be rt_is_flushed should be better?

