From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Thu, 13 Jan 2005 17:00:16 -0800
Message-ID: <20050114010016.GA16635@gate.ebshome.net>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <20050106070245.GA6539@gate.ebshome.net> <61A37C72-659C-11D9-8D70-000393C30512@freescale.com> <20050113212152.GA16041@gate.ebshome.net> <20050113215808.GA15124@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
        Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: J?rn Engel <joern@wohnheim.fh-wedel.de>
Content-Disposition: inline
In-Reply-To: <20050113215808.GA15124@wohnheim.fh-wedel.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2005 at 10:58:08PM +0100, J?rn Engel wrote:
> On Thu, 13 January 2005 13:21:52 -0800, Eugene Surovegin wrote:
> > 
> > It's a standard, period. If there is a PHY which isn't compliant I
> > guess it will not work anyway, but in this case, yes, we can use
> > PHY-specific link detection, but only in this case. I suspect you'll
> > have a hard time finding such PHY :)
> 
> http://www.broadcom.com/collateral/pb/5325-PB05-R.pdf
> 
> With some thinking and very little code, you can use this neat chip
> almost like a normal phy.

Yeah, but why would I want to? If you connect your MAC to any 5 PHYs 
my statement still stands, if directly to MII you don't need any PHY 
stuff at all, because link is always ON and speed/duplex is fixed.

In fact, we use different switch chips connected to PPC4xx directly. 
In this situation, in my NAPI IBM EMAC driver I just have special 
"PHY-less" case which is trivial "fixed settings" one. And all this 
PHY lib is completely unneeded bloat.

--
Eugene
