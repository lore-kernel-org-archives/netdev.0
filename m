From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Wed, 5 Nov 2014 11:09:53 +0100
Message-ID: <20141105100953.GA29022@magnum.frso.rivierawaves.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <20141104142020.GA6728@magnum.frso.rivierawaves.com>
 <1415176766.31613.7.camel@hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>, 764162@bugs.debian.org
To: Ian Campbell <ijc@hellion.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:53942 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaKEKKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 05:10:03 -0500
Received: by mail-wi0-f179.google.com with SMTP id h11so1501848wiw.6
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 02:10:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1415176766.31613.7.camel@hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2014 at 08:39:26AM +0000, Ian Campbell wrote:
> On Tue, 2014-11-04 at 15:20 +0100, Karl Beldan wrote:
> > On Sat, Nov 01, 2014 at 12:30:19PM -0300, Ezequiel Garcia wrote:
> > > Several users ([1], [2]) have been reporting data corruption with TSO on
> > > Kirkwood platforms (i.e. using the mv643xx_eth driver).
> > > 
> > > Until we manage to find what's causing this, this simple patch will make
> > > the TSO path disabled by default. This patch should be queued for stable,
> > > fixing the TSO feature introduced in v3.16.
> > > 
> > > The corruption itself is very easy to reproduce: checking md5sum on a mounted
> > > NFS directory gives a different result each time. Same tests using the mvneta
> > > driver (Armada 370/38x/XP SoC) pass with no issues.
> > > 
> > > Frankly, I'm a bit puzzled about this, and so any ideas or debugging hints
> > > are well received.
> > > 
> > 
> > Hi,
> > 
> > Can you try this :
> 
> It fixes things for me, thanks!
> 
> Tested-by: Ian Campbell <ijc@hellion.org.uk>
> 

Good thing, thanks for your feedbak Ian !
 
Karl
