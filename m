From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch -next v2] mv643xx_eth: potential null dereference
Date: Sat, 24 Jul 2010 00:15:14 +0200
Message-ID: <20100723221514.GJ26313@bicker>
References: <20100723101528.GF26313@bicker> <1279881177.24768.1623.camel@Joe-Laptop.home> <20100723110504.GG26313@bicker> <4C49C39E.8020502@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Saeed Bishara <saeed@marvell.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59996 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215Ab0GWWPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 18:15:34 -0400
Content-Disposition: inline
In-Reply-To: <4C49C39E.8020502@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 23, 2010 at 06:30:22PM +0200, walter harms wrote:
> this is a bit complicated, IMHO ppl have a bigger chance to discover what is going on
> with this version:
> 
>     if (!pd ) {
>        msp->t_clk = 133000000;
>        msp->tx_csum_limit = 9 * 1024;
>      }
>      else
>       {
> 	msp->t_clk = pd->t_clk ? pd->t_clk : 133000000 ;
>         msp->tx_csum_limit = pd->tx_csum_limit ? pd->tx_csum_limit : 9 * 1024;
>        }
> 

But then instead of 2 magic numbers we would have 4. :/

regards,
dan carpenter
