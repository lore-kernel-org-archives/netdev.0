From: "Frank Schneider" <twodipu@hotmail.com>
Subject: Re: Loop detected - calling function from different modules
Date: Sun, 03 Sep 2006 11:02:54 +0200
Message-ID: <BAY101-F34850DC65BCF9FA7ECEAF3AB320@phx.gbl>
References: <20060830142607.31c858cd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s30.bay0.hotmail.com ([65.54.246.230]:15468 "EHLO
	bay0-omc3-s30.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750946AbWICJC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 05:02:58 -0400
In-Reply-To: <20060830142607.31c858cd@localhost.localdomain>
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


hi Stephen,

you can check these:

  http://bcm43xx.berlios.de/
http://madwifi.org/

R
/frank


>From: Stephen Hemminger <shemminger@osdl.org>
>To: "Frank Schneider" <twodipu@hotmail.com>
>CC: netdev@vger.kernel.org
>Subject: Re: Loop detected  - calling function from different modules
>Date: Wed, 30 Aug 2006 14:26:07 -0700
>
>On Wed, 30 Aug 2006 22:58:17 +0200
>"Frank Schneider" <twodipu@hotmail.com> wrote:
>
> >
> > hi all,
> >
> > I am writing/customizing a network(wlan pc card) device driver for Linux
> > kernel 2.6.12
> > Think about I have two modules e.g. ath_pci and wlan module.
> > I can call a function from a   .c file which is implemented in a  .c 
>file in
> > wlan module by using EXPORT_SYMBOL macro..
> >
> > and i need to do same in reverse way, i.e. call a function from wlan 
>module
> > that is implemented in ath_pci module.
> >
> > I did the same way and its making but when I do  make install its 
>showing
> > following error:
> >
> > WARNING: Loop detected: /lib/modules/2.6.12/net/ath_pci.ko needs wlan.ko
> > which needs ath_pci.ko again!
> >
> > Please anybody tell how can I do this, any clue , please ?
> >
> > thanx in advance
> >
> > n.b. this question may consider as very naive since I am not good yet in
> > kernel hacking.. !!!!
> >
> > regards,
> > /Frank
>
>Where are these open source drivers so the wireless developers can help?
>
>--
>Stephen Hemminger <shemminger@osdl.org>

_________________________________________________________________
FREE pop-up blocking with the new MSN Toolbar - get it now! 
http://toolbar.msn.click-url.com/go/onm00200415ave/direct/01/


-- 
VGER BF report: U 0.864812
