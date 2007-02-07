From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: -mm patch] drivers/net/atl1/: possible cleanups
Date: Wed, 7 Feb 2007 01:24:05 +0100
Message-ID: <20070207002405.GA12958@stusta.de>
References: <20070129204528.eb8d695e.akpm@osdl.org> <20070206221229.GH27397@stusta.de> <20070206181910.4d27046a@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>,
	Xiong Huang <xiong_huang@attansic.com>,
	Chris Snook <csnook@redhat.com>, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:39954 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030352AbXBGAYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 19:24:03 -0500
Content-Disposition: inline
In-Reply-To: <20070206181910.4d27046a@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 06, 2007 at 06:19:10PM -0600, Jay Cliburn wrote:
> On Tue, 6 Feb 2007 23:12:29 +0100
> Adrian Bunk <bunk@stusta.de> wrote:
>...
> > This patch contains the following possible cleanups:
> > - move extern declarations to atl1.h
> > - make needlessly global code static
> 
> Adrian,
> 
> The atl1 driver currently follows this development pathway:
> 
> developer -> netdev#atl1 -> netdev#ALL -> -mm
> 
> Your patch is just a little bit out ahead of us.  Some of your suggested
> changes are already in the pipeline; we're just waiting for Jeff to
> merge netdev#atl1 into netdev#ALL.  Should be soon.
> 
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > 
> > ---
> > 
> > BTW: Can we get a MAINTAINERS entry for this driver?
> 
> Already submitted to netdev#atl1.
> 
> http://lkml.org/lkml/2007/2/3/174

:-)

> > -s32 atl1_setup_ring_resources(struct atl1_adapter *adapter);
> > -void atl1_free_ring_resources(struct atl1_adapter *adapter);
> > +
> > +extern char atl1_driver_name[];
> > +extern char atl1_driver_version[];
> 
> netdev#atl1 already has this change.
> 
> The rest of these I'll bundle up and submit to netdev#atl1, too.  Will
> that work for you?
>...

Do what you consider the right thing - I don't care how it gets into the 
various trees.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

