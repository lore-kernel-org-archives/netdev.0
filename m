From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv4/inetpeer.c: make a struct static
Date: Wed, 16 Mar 2005 20:40:20 -0800
Message-ID: <20050316204020.152b35cc.davem@davemloft.net>
References: <20050315144408.GL3189@stusta.de>
	<20050316145343.6e31ba6a.davem@davemloft.net>
	<20050316145448.5a45dddc.davem@davemloft.net>
	<20050317010821.GE3251@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050317010821.GE3251@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2005 02:08:21 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> inet_peer_unused_tailp might be referenced from other files via 
> inetpeer.h, but inet_peer_unused_head isn't referenced directly from 
> other files.

I misread your patch, I thought you were marking both
as static.  My bad, sorry.

I'll apply your patch, thanks.
