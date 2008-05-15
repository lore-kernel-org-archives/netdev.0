From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 9/15] BE NIC driver - Linux system abstraction files
Date: Thu, 15 May 2008 19:49:27 +0200
Message-ID: <20080515174927.GC30216@one.firstfloor.org>
References: <87mymrztse.fsf@basil.nowhere.org> <20080515173841.A0A48189004A@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Andi Kleen' <andi@firstfloor.org>, netdev@vger.kernel.org
To: subbu <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:38362 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbYEORlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 13:41:46 -0400
Content-Disposition: inline
In-Reply-To: <20080515173841.A0A48189004A@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2008 at 11:00:46PM +0530, subbu wrote:
> The reason why we have these abstractions is 
> because beclib functions are written as 
> OS neutral code and that needs a helper to
> do OS specific functions.  By eliminating
> SA, we will need to make  beclib Linux
> dependent - something that we would like avoid
> for ease of maintenance.  Is this approach
> not acceptable ?  What will is the recommended
> way to have part so a driver OS independent ?

We do not recommend it,  but recommend to write Linux
specific drivers. Operating systems are quite different and you
get far better drivers if you really optimize them for specific OS.
That's especially important for performance critical drivers like
yours for high speed networking.

Also splitting drivers into generic and OS specific parts typically
leads to poor and overcomplicated design.

Anyways if you really want abstraction elsewhere then use the Linux
names for it. But it's really not recommended.

-Andi

