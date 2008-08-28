From: David Brownell <david-b@pacbell.net>
Subject: Re: 2.6.27-rc ... iwl3945 regression?
Date: Thu, 28 Aug 2008 09:48:07 -0700
Message-ID: <200808280948.07358.david-b@pacbell.net>
References: <200808131735.42451.david-b@pacbell.net> <20080828164134.1cd3bb12@hskinnemo-gx745.norway.atmel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:38123 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751432AbYH1QsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 12:48:09 -0400
In-Reply-To: <20080828164134.1cd3bb12@hskinnemo-gx745.norway.atmel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 August 2008, Haavard Skinnemoen wrote:
> David Brownell <david-b@pacbell.net> wrote:
> > Does this sound familiar to anyone?  Got a fix that's better than
> > sticking to a 2.6.26 kernel?  :)
> 
> FWIW, I'm seeing the same thing with -rc4 and the b43 driver, so it's
> probably not a regression in iwl3945. I guess it could be something in
> mac80211?

It was separately suggested that I ignore the advice about no
software needing it, and enable CONFIG_WIRELESS_EXT_SYSFS ...
that did the trick for me.

That Kconfig helptext needs updating so it's not completely wrong.

- Dave


> I'm currently working around it by manually running iwconfig while
> nm-applet is bringing the interface up. A bit annoying, but it
> works...and it indicates that the driver works fine, but NetworkManager
> doesn't know that it's supposed to do any wireless configuration before
> bringing the interface up.
> 
> Haavard
> 


