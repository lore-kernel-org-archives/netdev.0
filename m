From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.7-rc3: waiting for eth0 to become free
Date: Tue, 8 Jun 2004 12:42:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608124215.291a7072@dell_ss3.pdx.osdl.net>
References: <1086722310.1682.1.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev Mailinglist <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <1086722310.1682.1.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 08 Jun 2004 21:18:30 +0200
Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:

> Hi!
> 
> On my laptop, when using a CardBus 3c59x-based NIC, I need to run
> "cardctl eject" so the system won't freeze when resuming. "cardctl
> eject" worked fine in 2.6.7-rc2-mm2, even when there were programs with
> network sockets opened (for example, Evolution mantaining a connection
> against an IMAP server): the card is ejected (well, not physically),
> even when there are ESTABLISHED connections.
> 
> However, starting with 2.6.7-rc3, "cardctl eject" hangs if a program
> holds any socket open. After a while the "unregister_netdevice: waiting
> for eth0 to become free" message starts appearing on the kernel message
> ring. The only apparent solution is killing that program, ejecting the
> card from its slot and wait until 3c59x.o usage count reaches zero.
> 
> Can someone tell me what's going on here?
> Thank you very much.

What protocols are you running? Is IPV6 loaded?
