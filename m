From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] kill ->accept_fastpath hook
Date: Thu, 10 Mar 2005 18:19:39 -0800
Message-ID: <20050310181939.4283ff02.davem@davemloft.net>
References: <20050309092628.3c9014db@dxpl.pdx.osdl.net>
	<422F44D8.3010009@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
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

Applied, thanks Jeff.
