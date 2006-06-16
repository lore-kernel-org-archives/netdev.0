From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Fri, 16 Jun 2006 14:42:41 -0700
Message-ID: <1150494161.26368.39.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC041BD16@NT-IRVA-0751.brcm.ad.broadcom.com>
 <87k67glrvl.fsf@blackdown.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:62725 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751495AbWFPVlu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 17:41:50 -0400
To: "Juergen Kreileder" <jk@blackdown.de>
In-Reply-To: <87k67glrvl.fsf@blackdown.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-16 at 23:20 +0200, Juergen Kreileder wrote:
> Michael Chan <mchan@broadcom.com> writes:
> 
> >
> > Did this use to work with an older kernel or older tg3 driver? If
> > yes, what version?
> 
> Works fine with 2.6.16 and earlier.
> 
> > Please also provide the full tg3 probing output during modprobe and
> > ifconfig up. Thanks.
> 
Looking at the patch history since 2.6.16, the only patch that could
have an impact is the one that enables TSO by default.

Please try turning TSO off to see if it makes a difference:

ethtool -K eth0 tso off

