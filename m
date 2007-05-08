From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Getting make net/built-in.o Error with 2.6.21.1 Build
Date: Tue, 08 May 2007 18:48:32 +0200
Message-ID: <1178642912.8628.70.camel@aeonflux.holtmann.net>
References: <463FB6B0.3070005@pcburn.com>
	 <a781481a0705071725i1d802dfejbcdaca4ab0a1ff55@mail.gmail.com>
	 <Pine.LNX.4.64.0705081740550.16923@twin.jikos.cz>
	 <a781481a0705080905l609dc925s93357e6eb0d4c318@mail.gmail.com>
	 <Pine.LNX.4.64.0705081815130.16923@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam.sharma@gmail.com>, chris@pcburn.com,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jiri Kosina <jikos@jikos.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:41079 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933855AbXEHQtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 12:49:19 -0400
In-Reply-To: <Pine.LNX.4.64.0705081815130.16923@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

> > Sure, my aim here was to only solve the _build breakage_ by fixing the 
> > Kconfig for this module (that used code from another kernel module 
> > without listing it in its dependencies). If, as you say, the real 
> > solution is that we should actually be taking out the offending call to 
> > the other module itself, then please go ahead -- I don't know much about 
> > the Bluetooth / HIDP subsytem anyway.
> 
> Converting the hid-ff drivers to be also transport-independent is on my 
> TODO list, but it didn't happen yet.
> 
> Marcel - are you aware of any devices currently supported by USB HID 
> force-feedback code, which have a bluetooth version, please? 

I haven't looked at all details for the PS3 controller, but that might
be the first one. In theory they can and at some point they will enter
the market.

> I'd propose the patch below, until I make the usbhid force-feedback code 
> transport independent. Thanks.
> 
> 
> 
> From: Jiri Kosina <jkosina@suse.cz>
> 
> [Bluetooth] HIDP - don't initialize force feedback
> 
> The current implementation of force feedback for HID devices is 
> USB-transport only and therefore calling hid_ff_init() from hidp code is 
> not going to work (plus it creates unwanted dependency of hidp on usbhid). 
> Remove the hid_ff_init() until either the hid-ff is made 
> transport-independent, or at least support for bluetooth transport is 
> added.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Under the condition that you remember to put it back once a generic FF
exists.

Regards

Marcel


