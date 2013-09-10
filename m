From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v3.2.y] inetpeer: Invalidate the inetpeer tree along
 with the routing cache
Date: Tue, 10 Sep 2013 14:49:24 -0400 (EDT)
Message-ID: <20130910.144924.1261528153855965155.davem@davemloft.net>
References: <5213A8BB.5070309@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	stable@vger.kernel.org, linux-kernel@vger.kernel.org
To: joseph.salisbury@canonical.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5213A8BB.5070309@canonical.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joseph Salisbury <joseph.salisbury@canonical.com>
Date: Tue, 20 Aug 2013 13:34:51 -0400

> Please consider including mainline commit 5faa5df in the next v3.2.y
> release.  It was included in the mainline tree as of v3.3-rc7.  It has
> been tested and confirmed to resolve
> http://bugs.launchpad.net/bugs/1205741 .
> 
> commit 5faa5df1fa2024bd750089ff21dcc4191798263d
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Tue Mar 6 21:20:26 2012 +0000
> 
>     inetpeer: Invalidate the inetpeer tree along with the routing cache
> 
> 
> Also note that commit 5faa5df introduced a race condition that is fixed
> by mainline commit 55432d2, so that commit would also be required:
> 
> commit 55432d2b543a4b6dfae54f5c432a566877a85d90
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Jun 5 03:00:18 2012 +0000
> 
>     inetpeer: fix a race in inetpeer_gc_worker()

Queued up, thanks.
