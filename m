From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: keyboard dead with 45b5035
Date: Tue, 19 Feb 2008 06:50:18 +0100
Message-ID: <20080219065018.729b56f2@mjolnir.drzeus.cx>
References: <20080218185305.48a67587@mjolnir.drzeus.cx>
	<200802182050.01964.rjw@sisk.pl>
	<20080218215012.0462a302@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Laszlo Attila Toth <panther@balabit.hu>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:55203 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007AbYBSFuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 00:50:51 -0500
In-Reply-To: <20080218215012.0462a302@mjolnir.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Feb 2008 21:50:12 +0100
Pierre Ossman <drzeus-list@drzeus.cx> wrote:

> On Mon, 18 Feb 2008 20:50:01 +0100
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > On Monday, 18 of February 2008, Pierre Ossman wrote:
> > > The patch "[RTNETLINK]: Send a single notification on device state changes." kills (at least)
> > > the keyboard here. Everything seems to work fine in single user mode, but when init starts
> > > spawning of logins, the keyboard goes bye-bye. Even the power button is ignored. :/ 
> > 
> > Please try with the patch from http://lkml.org/lkml/2008/2/18/331 .
> > 
> 
> That solved it.
> 

Perhaps not quite. When I returned to my laptop this morning, the keyboard was gone again. Did a hard reboot, and the machine locked up a few seconds after starting X. I'll see if it can be reproduced...

Rgds
-- 
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  PulseAudio, core developer          http://pulseaudio.org
  rdesktop, core developer          http://www.rdesktop.org
