From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH V2] staging: r8723au: Fix build warnings
Date: Wed, 9 Apr 2014 11:44:12 -0700
Message-ID: <20140409184412.GA9916@kroah.com>
References: <1397066159-14690-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
	Jes Sorensen <Jes.Sorensen@redhat.com>, kbuild-all@01.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37203 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933323AbaDISlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 14:41:40 -0400
Content-Disposition: inline
In-Reply-To: <1397066159-14690-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 09, 2014 at 12:55:59PM -0500, Larry Finger wrote:
> The kbuild test robot reports the following:
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   75ff24fa52f0cc512ceee4c377632b91a3a80811
> commit: 9176303c404741b2f96796466437f2badf6e289b staging: r8723au: Turn on build of new driver
> date:   4 days ago
> config: make ARCH=avr32 allyesconfig
> 
> All warnings:
> 
> >> drivers/staging/rtl8723au/include/rtw_mlme.h:620: warning: 'rtw_set_roaming' declared inline after being called
>    drivers/staging/rtl8723au/include/rtw_mlme.h:620: warning: previous declaration of 'rtw_set_roaming' was here
> >> drivers/staging/rtl8723au/include/rtw_mlme.h:621: warning: 'rtw_to_roaming' declared inline after being called
>    drivers/staging/rtl8723au/include/rtw_mlme.h:621: warning: previous declaration of 'rtw_to_roaming' was here
> --
>    drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c: In function 'Hal_EEValueCheck':
> >> drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c:2277: warning: comparison is always true due to limited range of data type
> 
> The first two warnings are fixed by making the two prototypes be "inline" to match
> the actual routine.

This sentance doesn't match the patch contents anymore :(
