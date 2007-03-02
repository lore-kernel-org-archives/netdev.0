From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BUG][SECURITY] Re: Weird problem with PPPoE on tap
 interface
Date: Fri, 02 Mar 2007 13:18:14 -0800 (PST)
Message-ID: <20070302.131814.23015047.davem@davemloft.net>
References: <20070225195455.GC3318@florz.florz.dyndns.org>
	<20070226102908.GD3318@florz.florz.dyndns.org>
	<20070228123844.GA28150@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mostrows@speakeasy.net
To: florz@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38807
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965648AbXCBVSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 16:18:15 -0500
In-Reply-To: <20070228123844.GA28150@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@gmx.de>
Date: Wed, 28 Feb 2007 13:38:44 +0100

> As noone seems to have an opinion on this: Here is a patch that does
> work for me and that should solve the problem as far as that is easily
> possible. It is based on the assumption that an interface's ifindex is
> basically an alias for a local MAC address, so incoming packets now are
> matched to sockets based on remote MAC, session id, and ifindex of the
> interface the packet came in on/the socket was bound to by connect().

I agree with your analysis and have applied your patch.

Another way to implement this would have been to store the
pre-computed ifindex on the kernel side sockaddr.

Thanks.
