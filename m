From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Where is netif_rx() not safe to use?
Date: Mon, 12 May 2003 11:44:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030512154434.GD27111@gtf.org>
References: <3ebfa567b38e59.35614148@notright> <20030512145943.GB27111@gtf.org> <slrnbbveq6.321.lunz@stoli.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
Content-Disposition: inline
In-Reply-To: <slrnbbveq6.321.lunz@stoli.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 12, 2003 at 03:16:55PM +0000, Jason Lunz wrote:
> jgarzik@pobox.com said:
> >> I'd like to know if there are situations where netif_rx() is not safe to use. 
> >> For example, is it safe to call from a timer or from dev->poll()?
> > 
> > Sure, that's fine.
> 
> from dev->poll()? It could work, but that's abusing the napi design.
> netif_rx() is for non-napi drivers.  If a dev has a ->poll() method, it
> should use netif_receive_skb().

agreed.

	Jeff
