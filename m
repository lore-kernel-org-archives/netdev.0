From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.4.28-pre4-bk3] forcedeth: Gigabit ethernet support and media detection changes
Date: Sun, 17 Oct 2004 14:38:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017133807.GA21964@infradead.org>
References: <Pine.LNX.4.44.0410171216490.29815-100000@dbl.q-ag.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, marcelo.tosatti@cyclades.com, blazara@nvidia.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410171216490.29815-100000@dbl.q-ag.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 17, 2004 at 12:27:21PM +0200, Manfred Spraul wrote:
> Backport of the 0.29 forcedeth driver to 2.4.
> Changes:
> - lots of bugfixes.
> - completely rewritten PHY initialization and media detection
> - gigabit ethernet support
> 
> The actual backport was done by Jane Liu from NVIDIA:
> 
> - all occurrences of msleep changed to mdelay

that sounds wrong - mdelay spins instead of sleeping.  Better provide
a msleep backport.

> - SET_NETDEV_DEV calls removed

doesn't recent 2.4 have a noop variant of it?

> - module_param call changed to MODULE_PARM

Didn't rusty backport module_param to 2.4 a while ago?
