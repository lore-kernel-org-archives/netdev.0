From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert ircomm to seq_file interface
Date: Tue, 19 Aug 2003 21:20:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819212009.36a8dc03.davem@redhat.com>
References: <20030818123142.6369fbff.shemminger@osdl.org>
	<20030818200923.GC6577@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, shemminger@osdl.org,
   irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20030818200923.GC6577@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 13:09:23 -0700
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> On Mon, Aug 18, 2003 at 12:31:42PM -0700, Stephen Hemminger wrote:
> > Convert ircomm /proc interface to seq_file.
> > 
> > Note: don't need spin_lock_irq because list is not ever locked
> > from inside interrupt context.
> 
> 	I don't agree with this change.

I'll let you guys work this one out.  Let me know when a
final version of the patch is ready.
