From: Radu Potop <wooptoo@gmail.com>
Subject: Re: rtl8180 driver in master/ad-hoc mode
Date: Fri, 12 Feb 2010 19:53:22 +0200
Message-ID: <4B759592.5040807@gmail.com>
References: <4B756B4C.2090204@gmail.com> <20100212150853.GA4983@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:63870 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978Ab0BLRx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 12:53:26 -0500
Received: by fxm20 with SMTP id 20so2597272fxm.1
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2010 09:53:25 -0800 (PST)
In-Reply-To: <20100212150853.GA4983@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	I contacted Markus Gothe from rtl-wifi and he was interested in updating the 
driver/providing patches. It would be nice to collaborate with him on this one.
	I'll keep you updated if he posts anything on the rtl-wifi mailing list.

-Radu

On 02/12/2010 05:08 PM, John W. Linville wrote:
> On Fri, Feb 12, 2010 at 04:53:00PM +0200, Radu Potop wrote:
>
>> 	I noticed that the rtl8180 (Realtek wireless PCI adapter) driver for
>> Linux doesn't support master or ad-hoc mode. However the rtl-wifi driver
>> from http://rtl-wifi.sourceforge.net does support these modes.
>> 	After a bit of investigation, I found out that the driver from the
>> kernel is not maintained by its original author anymore (no changes since
>> 2007), while rtl-wifi development is active.
>
> A bit too little investigation, it seems.  The rtl8180 driver doesn't
> get lots of attention, but it has been hit several times since 2007.
> As for master and ad-hoc modes, I've recently taken interest there
> and expect to be adding patches shortly.
>
>> 	My question is if rtl-wifi will make it into the kernel? rtl-wifi is
>> actually a fork of the old driver, but with a lot of added functionality.
>> I'm sure that a lot of folks would like to use their hardware to its full
>> potential.
>
> No it will not.  For one, svn indicates rtl-wifi is nowhere near as
> active as you indicate:
>
> 	/home/linville/svn/rtl-wifi
> 	[linville-t400.local]:>  svn log
> 	------------------------------------------------------------------------
> 	r83 | falmouth | 2008-07-09 08:52:33 -0400 (Wed, 09 Jul 2008) | 1 line
>
> 	our CCMP, TKIP and WEP modules names end in -rtl
>
> Beyond that, no one from there is posting any patches and in any case
> it is rather rare to simply drop one more-or-less working driver in
> favor of another one simply because it appears from nowhere.
>
> Anyway, as I indicated I have been taking more interest in rtl8180
> lately and I expect it to be greatly improved at least in time for
> 2.6.35 (since the 2.6.34 development cycle will be ending soon).
>
> Hth!
>
> John
