From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Mon, 22 Mar 2004 00:47:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040322004723.A17690@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <405DDDC6.7030007@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <405DDDC6.7030007@pobox.com>; from jgarzik@pobox.com on Sun, Mar 21, 2004 at 01:24:06PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> Need to add a netif_running() check to the 'if' test at the top of the 
> quote.
> 
> Are you (or somebody else?) interested in reviewing all the in-tree NAPI 
> drivers, and seeing if other drivers have this bug?  I think 8139cp.c 
> does at least, maybe e100 too...  Such a fix would need to go into 2.4.x 
> as well.

Ok, I'll check for the race against dev_close.

--
Ueimor
