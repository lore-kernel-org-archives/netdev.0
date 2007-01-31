From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [linux-pm] [RFC] Runtime power management on ipw2100
Date: Wed, 31 Jan 2007 11:39:01 +0100
Message-ID: <20070131103901.GB19643@elf.ucw.cz>
References: <20070131075249.GA22115@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ipw2100-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-pm@lists.osdl.org
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:49176 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932951AbXAaKjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:39:14 -0500
Content-Disposition: inline
In-Reply-To: <20070131075249.GA22115@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> Based on previous discussions, I've implemented a rough attempt at 
> providing some level of basic runtime power management on the ipw2100 
> chipset. This patch does the following:
> 
> 1) On load, it initialises the hardware and then quiesces it again
> 2) On interface up, it powers the hardware back up
> 3) On interface down, it powers the hardware down and puts the chip in 
> D3
> 4) It attempts to behave correctly over suspend/resume - ie, if the 
> interface was down beforehand, it will ensure that the chip is powered 
> down

I'm not a wireless guru, but patch certainly looks okay to me.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
