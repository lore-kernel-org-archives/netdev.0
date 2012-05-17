From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for comms devices.
Date: Thu, 17 May 2012 09:39:25 -0700
Message-ID: <20120517163925.GA14877@kroah.com>
References: <cover.1337203535.git.sarah.a.sharp@linux.intel.com>
 <20120516224528.GA25936@xanatos>
 <20120516232019.GA960@kroah.com>
 <20120517045220.GA4772@xanatos>
 <20120517144951.GB27597@kroah.com>
 <20120517162922.GC4967@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>,
	linux-bluetooth@vger.kernel.org,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	libertas-dev@lists.infradead.org, users@rt2x00.serialmonkey.com
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:45180 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933200Ab2EQQja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 12:39:30 -0400
Received: by pbbrp8 with SMTP id rp8so2744103pbb.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 09:39:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120517162922.GC4967@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 09:29:22AM -0700, Sarah Sharp wrote:
> One of the problems with this patch is that several mailing lists
> rejected it because of the large number of recipients in the Cc list,
> even when just the mailing lists were on the Cc list.  Should I break it
> up into a series of patches per driver?

No need to do that, I can just take it.

> Also, do I need to wait on acks from the other maintainers for this
> change?  My instinct is no, since it shouldn't change the behavior of
> their drivers with the USB devices that are out there today, but I don't
> want to step on anyone's toes.

Don't worry about it, we change USB drivers in other trees all the time :)

greg k-h
