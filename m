From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Sat, 16 Aug 2003 18:09:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030816180946.228b5909.davem@redhat.com>
References: <20030815154608.56cf0551.shemminger@osdl.org>
	<20030815230546.GA31831@bougret.hpl.hp.com>
	<20030816052048.5858d68a.davem@redhat.com>
	<20030817001405.GA1916@bougret.hpl.hp.com>
	<20030816175851.58a2c179.davem@redhat.com>
	<20030817011131.GA2120@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, shemminger@osdl.org,
   irda-users@lists.sourceforge.net, netdev@oss.sgi.com, lists@mdiehl.de
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20030817011131.GA2120@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 16 Aug 2003 18:11:31 -0700
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> Would it be possible for Stephen to use some real IrDA hardware so
> that he can double check what he is doing ?

And alternatively, what?  We let known bugs sit in the tree
because of IRDA?

We've had to edit and hack on lots of obscure ISA ethernet drivers to
do this so far that probably nobody has tried to use in years and very
few people have access to.  Not just trivial changes, we've had to
rewrite some of their probe routines in some cases.

The work simply must be done.

If we add bugs, the first person who tries to use it will find out
and report the problem.
