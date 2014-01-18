From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: add build-time checks for msg->msg_name size
Date: Sat, 18 Jan 2014 13:05:05 +0100
Message-ID: <20140118120505.GA6341@order.stressinduktion.org>
References: <20140117215314.GC7562@noise.didjital.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Steffen Hurrle <steffen@hurrle.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47673 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbaARMFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 07:05:07 -0500
Content-Disposition: inline
In-Reply-To: <20140117215314.GC7562@noise.didjital.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 10:53:15PM +0100, Steffen Hurrle wrote:
> This is a follow-up patch to f3d3342602f8bc ("net: rework recvmsg
> handler msg_name and msg_namelen logic").
> 
> DECLARE_SOCKADDR validates that the structure we use for writing the
> name information to is not larger than the buffer which is reserved
> for msg->msg_name (which is 128 bytes). Also use DECLARE_SOCKADDR
> consistently in sendmsg code paths.
> 
> Signed-off-by: Steffen Hurrle <steffen@hurrle.net>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
