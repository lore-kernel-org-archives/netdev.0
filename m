From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] kill ->accept_fastpath hook
Date: Wed, 9 Mar 2005 10:55:51 -0800
Message-ID: <20050309105551.09a7926c@dxpl.pdx.osdl.net>
References: <20050309092628.3c9014db@dxpl.pdx.osdl.net>
	<422F44D8.3010009@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <422F44D8.3010009@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 09 Mar 2005 13:47:52 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Trivial reordering of netdevice structure to save four bytes.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> If we are twiddling struct net_device, might as well kill this hook. 
> Never called AFAICS, and only assigned -- to a no-op stub -- in one driver.
> 
> Signed-off-by: Jeff Garzik <jgarzik@pobox.com>
> 
yes, kill it.
