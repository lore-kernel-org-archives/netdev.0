From: "Frank Schneider" <twodipu@hotmail.com>
Subject: Re: Loop detected - calling function from different modules
Date: Thu, 31 Aug 2006 13:10:41 +0200
Message-ID: <BAY101-F33F0ABEDED7557244B41D0AB3F0@phx.gbl>
References: <1157018266.3065.17.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s21.bay0.hotmail.com ([65.54.246.221]:50285 "EHLO
	bay0-omc3-s21.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1751271AbWHaLLC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 07:11:02 -0400
In-Reply-To: <1157018266.3065.17.camel@ux156>
To: johannes@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Dear Johannes,

I just got an idea, may be not usefull,  but I am gonna try:

If I assign a function which is implemented in ath_pci module to
hard_start_xmit
and do  my little work and call  the actual function to xmit data frame in 
wlan module.
that I can do..
accordingly I will pass the concern structure sk_buff that contain data 
frame..
that will serve my purpose as well as normal data frame is suppose to send 
out from the device, AP.

can I do it ?
I will let you know, if I success...

/Frank



>From: Johannes Berg <johannes@sipsolutions.net>
>
> > Any suggestions to do that please ?
>
>d80211 has a hardware definition struct that is registered by the driver
>and contains a callback that is called for each frame. This is the
>direction you should take as well:
>
>    hard_start_xmit (generic code)
>calls
>    hardware_xmit (your module code, e.g. in a struct wlan_device)
>
>johannes
>-
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE! 
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/

