From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] convert ircomm to seq_file interface
Date: Wed, 20 Aug 2003 09:48:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820164853.GB14035@bougret.hpl.hp.com>
References: <20030818123142.6369fbff.shemminger@osdl.org> <20030818200923.GC6577@bougret.hpl.hp.com> <20030819212009.36a8dc03.davem@redhat.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030819212009.36a8dc03.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 19, 2003 at 09:20:09PM -0700, David S. Miller wrote:
> On Mon, 18 Aug 2003 13:09:23 -0700
> Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:
> 
> > On Mon, Aug 18, 2003 at 12:31:42PM -0700, Stephen Hemminger wrote:
> > > Convert ircomm /proc interface to seq_file.
> > > 
> > > Note: don't need spin_lock_irq because list is not ever locked
> > > from inside interrupt context.
> > 
> > 	I don't agree with this change.
> 
> I'll let you guys work this one out.  Let me know when a
> final version of the patch is ready.

	Oh, that's fairly simple. You just need to revert the
spin_lock() to a spin_lock_irqsave().
	By the way, I would prefer Stephen to not rock the boat when
it come to locking, I know that the locking of the IrDA stack is still
"fragile" in areas.
	Have fun...

	Jean
