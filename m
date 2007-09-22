From: Alan Cox <alan@redhat.com>
Subject: Re: bind and O_NONBLOCK
Date: Sat, 22 Sep 2007 13:35:56 -0400
Message-ID: <20070922173556.GA26346@devserv.devel.redhat.com>
References: <46F35DD9.4000909@redhat.com> <20070922161414.GA29637@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>, Alan Cox <alan@redhat.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757418AbXIVRgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2007 13:36:08 -0400
Content-Disposition: inline
In-Reply-To: <20070922161414.GA29637@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 22, 2007 at 08:14:15PM +0400, Evgeniy Polyakov wrote:
> of operations. There are four ways where bind can fail:
> 
> 1. unsufficient rights - nothing can help here
> 2. there is no memory - async binding can not help here too, since it
> 	some memory just has to be allocated to save async request
> 	somewhere.
> 3. socket is locked.
> 4. addres is being bound is in use.

For most protocols yes - but not all. For things like IP specifying O_NDELAY
is meaningless on a bind it will always complete on the spot as you say

