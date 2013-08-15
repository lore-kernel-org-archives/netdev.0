From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate
 module unloading
Date: Thu, 15 Aug 2013 08:42:21 +0200
Message-ID: <20130815084221.3339142f@mitra.spranger.biz>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
	<1376384922-8519-3-git-send-email-b.spranger@linutronix.de>
	<20130813174814.GE4098@kroah.com>
	<20130814091946.2643a124@mitra.spranger.biz>
	<20130814163311.GB7208@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:60775 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331Ab3HOGmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 02:42:25 -0400
In-Reply-To: <20130814163311.GB7208@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Aug 2013 09:33:11 -0700
Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:

> Step 4 should have told UIO that it was gone and had it shut everything
> down properly, so that there would not be a crash.
The MFD driver only knows about a specific MFD cell. Through
enable/disable callbacks the driver could tell UIO ...hm... whom? what?

Neither the MFD driver nor the MFD core knows something about a specific
UIO driver. But only that specific UIO driver knows about the device
node activities. 

> > > You shouldn't need a module reference for this type of thing.
> > The driver uio_pdrv has no chance to recognize that the underlaying platform
> > device has gone.
> The mfd driver could tell it that it is gone, right?
It could tell, but whom and how?

Regards
    Benedikt Spranger
