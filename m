From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] rtnl_unlock/lock in sch_api.c TRY3
Date: Thu, 31 Mar 2005 20:39:19 -0800
Message-ID: <20050331203919.08b7acff.davem@davemloft.net>
References: <Pine.LNX.4.62.0503312309160.3390@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0503312309160.3390@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 23:11:06 +0300 (EEST)
"Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro> wrote:

> Hello!
> 
> Trying to load a custom module (same for teql but I didn't tried it)
> whan the qdisc module is not loaded, makes tc hang.
> This is because qdisc_create aquires rtnl_sem and then tries to load a module 
> that tries to register_netdev (that tries to aquire the same rtnl_sem).
> Applying this patch makes the problem go away.
> 
> The patch was tested under 2.6.11.6.
> 
> Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
> 
> Please apply.

Looks good, applied, thanks Catalin.
