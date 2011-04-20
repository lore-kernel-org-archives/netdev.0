From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] usbnet: Resubmit interrupt URB more often
Date: Wed, 20 Apr 2011 01:24:31 -0700 (PDT)
Message-ID: <20110420.012431.104074243.davem@davemloft.net>
References: <1303233066.2988.14.camel@bwh-desktop>
	<20110419175037.AADD22052B@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: pstew@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42669
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750808Ab1DTIZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:25:05 -0400
In-Reply-To: <20110419175037.AADD22052B@glenhelen.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Stewart <pstew@chromium.org>
Date: Tue, 19 Apr 2011 10:44:12 -0700

> The second class of device are those which shut down the device
> during suspend.  During a suspend-resume cycle, the device is
> re-enumerated at system resume, and for whatever reason
> usbnet_resume may be called on the device during the call-tree
> from usbnet_open-> usb_autopm_get_interface, which may cause a
> race where the first change above may cause the bh to submit the
> interrupt urb before usbnet_open() does.  As a result, I've added
> an EALREADY check and a fix to urb.c to send one.

You'll need to submit the generic urb submission change via the USB
maintainers, not networking.
