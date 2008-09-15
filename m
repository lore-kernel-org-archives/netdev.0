From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for September 13 (3c509)
Date: Mon, 15 Sep 2008 08:03:57 -0700
Message-ID: <20080915080357.2eaae073.randy.dunlap@oracle.com>
References: <20080913162344.ab395285.sfr@canb.auug.org.au>
	<20080914141757.899f71eb.randy.dunlap@oracle.com>
	<20080915141149.GA10002@cs181140183.pp.htv.fi>
	<48CE70CC.7020901@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, Kay Sievers <kay.sievers@vrfy.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Hannes Reinecke <hare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:28119 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbYIOPEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 11:04:23 -0400
In-Reply-To: <48CE70CC.7020901@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Sep 2008 16:27:24 +0200 Hannes Reinecke wrote:

> Hi Adrian,
> 
> Adrian Bunk wrote:
> > On Sun, Sep 14, 2008 at 02:17:57PM -0700, Randy Dunlap wrote:
> >> drivers/net/3c509.c fails (CONFIG_PM=y) with:
> >>
> >> drivers/built-in.o:(.data+0x7dcc): undefined reference to `el3_resume'
> >> drivers/built-in.o:(.data+0x7e08): undefined reference to `el3_resume'
> >>
> >> It seems that this function does not exist in the source file.
> > 
> > 
> > It got removed by:
> > 
> > 
> > commit 107aeb9753159da848f066b26557f0aaab900a90
> > Author: Hannes Reinecke <hare@suse.de>
> > Date:   Wed Sep 10 14:16:04 2008 +0200
> > 
> >     Driver core: Use dev_get_drvdata() accessors
> >     
> >     Deprecated direct access to the ->driver_data field and
> >     use accessors throughout.
> >     
> >     Signed-off-by: Hannes Reinecke <hare@suse.de>
> >     Cc: Kay Sievers <kay.sievers@vrfy.org>
> >     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> > 
> Sorry. Here it is again.

Ack, that [attached] patch fixes the build.

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
