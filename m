From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Mon, 18 Aug 2003 09:03:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818090313.7f153d7a.shemminger@osdl.org>
References: <20030815154608.56cf0551.shemminger@osdl.org>
	<20030815230546.GA31831@bougret.hpl.hp.com>
	<20030816052048.5858d68a.davem@redhat.com>
	<20030817001405.GA1916@bougret.hpl.hp.com>
	<20030816175851.58a2c179.davem@redhat.com>
	<20030817011131.GA2120@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, "David S. Miller" <davem@redhat.com>,
   irda-users@lists.sourceforge.net, netdev@oss.sgi.com, lists@mdiehl.de
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20030817011131.GA2120@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 16 Aug 2003 18:11:31 -0700
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> On Sat, Aug 16, 2003 at 05:58:51PM -0700, David S. Miller wrote:
> > On Sat, 16 Aug 2003 17:14:05 -0700
> > Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:
> > 
> > > 	Curently driver do work properly (including SMP).
> > 
> > Users can hold onto procfs files after the driver
> > modules are unloaded.  For example:
> > 
> > rmmod eth0 </proc/sys/net/ipv4/eth0/whatever
> > 
> > If IRDA creates any procfs files for devices that are
> > registered, you have this problem too.
> > 
> > This is not fixable without first making sure every net driver in the
> > entire tree abides by a few rules, and that is what Stephen is doing.
> 
> 	No problem, it's just that with the total lack of testing of
> IrDA in 2.6.0, I'm a bit nervous, as always. Would it be possible for
> Stephen to use some real IrDA hardware so that he can double check
> what he is doing ?
> 	Have fun...

I have some, but haven't used it so far.
For the load/unload testing, it is possible to setup irtty (and irlan)
without real hardware.  So far, haven't had to change the hardware drivers.
