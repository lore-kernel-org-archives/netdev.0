From: Willy Tarreau <w@1wt.eu>
Subject: Re: SKGE backport to 2.4 : success
Date: Mon, 6 Nov 2006 22:24:29 +0100
Message-ID: <20061106212429.GA5383@1wt.eu>
References: <20061028205707.GA722@1wt.eu> <20061104210855.GB4778@1wt.eu> <20061106105609.7c115cb6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:773 "EHLO 1wt.eu") by vger.kernel.org
	with ESMTP id S1753825AbWKFV0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 16:26:23 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061106105609.7c115cb6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 06, 2006 at 10:56:09AM -0800, Stephen Hemminger wrote:
> On Sat, 4 Nov 2006 22:08:55 +0100
> Willy Tarreau <w@1wt.eu> wrote:
> 
> > Hi Stephen,
> > 
> > I don't know if you received my mail since I got no reply.
> > 
> > Thanks in advance for your comments,
> > Willy
> > 
> > On Sat, Oct 28, 2006 at 10:57:07PM +0200, Willy Tarreau wrote:
> > > Hi Stephen,
> > > 
> > > In my own kernels, I've added your backport of SKGE to 2.4 that I found
> > > here :
> > > 
> > >    http://developer.osdl.org/shemminger/releases/skge-sky2-backport.tar.bz2
> > > 
> > > It seems to work pretty well compared to the original syskonnect driver
> > > (up to and including 8.36). Several people around me have reported very
> > > slow NFS operations with the official driver, which I finally attributed
> > > to a strange effect of UDP packets not going out after a while until they
> > > get "pushed" by a TCP packet. I even noticed the problem at the company
> > > and we turned the NFS server to an unused 100 Mbps card to workaround the
> > > problem before being able to fully ananlyze the problem.
> > > 
> > > It seems your driver is getting mature and its performance is very close to
> > > the official one, while its code is smaller and apparently more reliable. I
> > > was thinking about merging it in mainline 2.4 as a fix for people having
> > > trouble with the syskonnect driver. It might also be easier to backport fixes
> > > from 2.6 to 2.4 when the driver is the same.
> > > 
> > > I don't think we risk any regression because it won't replace an existing
> > > driver, but will provide one to people who are used to download new versions
> > > from an external tree.
> > > 
> > > Also, I'm not yet sure whether I would also backport the sky2 driver, because
> > > I know about a handful boxes running in production with the official one with
> > > 88E8053 chips at high packet rates with no trouble at all. Anyway, as long as
> > > the backport does not prevent them from using the external driver, there
> > > should be no problem.
> > > 
> > > I'd like to get your opinion on this matter, and of course, Jeff's and Davem's.
> > > 
> > > Thanks in advance,
> > > Willy
> > > 
> 
> 
> The backport needs to be updated. It is of older code.  I plan to do a new
> backport this week. The backport version doesn't use NAPI, because of issues
> with not wanting to change netdevice.h. For a good 2.4 version, I would
> make a version that was closer to 2.6 code (using NAPI).

That would be perfect, it would make backport of fixes even easier. I have
turned last version into a patch against 2.4.33 for in-tree inclusion, so
if you're interested in getting it for the Config.in, Makefiles and
Configure.help, do not hesitate.

> I did the backport because one of the equipment donors gave a VPN box whose
> base OS is RHEL based on 2.4.

It's amazing how having the hardware stimulates development, isn't it? :-)

Tbanks,
Willy

