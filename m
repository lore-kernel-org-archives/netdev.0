From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Wed, 18 Apr 2007 01:39:07 +0200
Message-ID: <200704180139.07442.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <200704172236.43280.peter.missel@onlinehome.de> <20070417223027.GA9517@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:52723 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031298AbXDQXjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 19:39:16 -0400
In-Reply-To: <20070417223027.GA9517@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

and thanks again for the quick replies.

> > Does this patchset work against kernel 2.6.18, or, better yet, is there a
> > separate source package that lets me build the current driver on this
> > older kernel?
>
> Hardly: the r8169 driver has been modified by ~40 patches from 2.6.18 to
> now.
>
> There is an ugly hack^W^W quick backport for 2.6.18 at:
> http://www.fr.zoreil.com/people/francois/backport/r8169/20070418-00
>
> It compiles but I do not know if it works and I strongly suggest to use
> a more recent kernel package anyway.

I'll do my best - a kernel update is certainly not possible on this particular 
machine, simply because it is a user workstation that is actually being 
used ;)

Also, mii-tool doesn't appear to be included anywhere in this (SuSE 10.2 x64) 
installation, so I'll have to look into building this from source.

Meanwhile, a new bit of information that maybe gives a hint: 

ethtool -d shows reg 0x6C "PHY status" changes from 0x6b (erroneous 100TX 
link) to 0x73 (correct 1000TX link). What ethtool dumps aren't MII registers, 
so I doubt that this tells us anything useful, but here it is anyway.

Bonne nuit!

Peter
