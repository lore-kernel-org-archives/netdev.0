From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Mon, 18 Aug 2003 10:08:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818170850.GE5992@bougret.hpl.hp.com>
References: <20030815154608.56cf0551.shemminger@osdl.org> <20030815230546.GA31831@bougret.hpl.hp.com> <20030816052048.5858d68a.davem@redhat.com> <20030817001405.GA1916@bougret.hpl.hp.com> <20030816175851.58a2c179.davem@redhat.com> <20030817011131.GA2120@bougret.hpl.hp.com> <20030818090313.7f153d7a.shemminger@osdl.org> <20030818165024.GB5992@bougret.hpl.hp.com> <20030818165321.GH24693@gtf.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com, lists@mdiehl.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030818165321.GH24693@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2003 at 12:53:21PM -0400, Jeff Garzik wrote:
> On Mon, Aug 18, 2003 at 09:50:24AM -0700, Jean Tourrilhes wrote:
> > 	You can use irtty-sir with a cross-over serial cable between
> > two PCs. IrLAN is a bit flaky and no longer maintained, I would
> > recommend to try IrNET or RfCOMM.
> 
> Can we remove IrLAN in 2.6, then?  :)
> 
> 	Jeff

	The problem is that we don't have another implementation of
IrLAN. There are a few devices that talk IrLAN (NetBeamIr, Win95), and
for those there is no alternative and IrLAN works good enough with
them (I test it every few months). No need to remove it if it still
works...

	If you really are in cleanup mood, you can kill :
		o irtty (broken - replaced by irtty-sir + sir-dev)
		o toshoboe (no spinlock - replaced by donauboe)
		o smc-ircc (flaky - replaced by smsc-ircc2)
		o ep7211_ir (obsolete hardware, unmaintained)
	Happy ?

	Have fun...

	Jean
