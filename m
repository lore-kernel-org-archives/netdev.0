From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [Orinoco-devel] Re: [8/14] Orinoco driver updates - PCMCIA initialization cleanups
Date: Fri, 25 Feb 2005 08:02:26 +0100
Message-ID: <20050225070226.GA30541@isilmar.linta.de>
References: <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain> <20050224040024.GI32001@localhost.localdomain> <20050224040052.GJ32001@localhost.localdomain> <20050224065527.GA8931@isilmar.linta.de> <421D8241.9020608@pobox.com> <20050225050310.GF10725@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jgarzik@pobox.com>, Pavel Roskin <proski@gnu.org>,
	Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050225050310.GF10725@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 25, 2005 at 04:03:10PM +1100, David Gibson wrote:
> On Thu, Feb 24, 2005 at 02:29:05AM -0500, Jeff Garzik wrote:
> > Dominik Brodowski wrote:
> > >>@@ -184,6 +186,7 @@
> > >>	dev_list = link;
> > >>
> > >>	client_reg.dev_info = &dev_info;
> > >>+	client_reg.Attributes = INFO_IO_CLIENT | INFO_CARD_SHARE;
> > >
> > >
> > >That's not needed any longer for 2.6.
> > 
> > So who wants to send the incremental update patch?  :)
> 
> Guess I will.  See below.
> 
> Any particular reason the field and associated constants haven't been
> exunged from the tree, since they're no longer used?

To keep external drivers compiling -- it'll be removed soon, though.

	Dominik
