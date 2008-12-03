From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 15/39] i2400m: host-to-device protocol definitions
Date: Tue, 2 Dec 2008 18:06:53 -0800
Message-ID: <200812021806.54231.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <b488d4082cea6779ade2b487efd0ce6a1ad9c343.1227691434.git.inaky@linux.intel.com> <1227780265.3809.55.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:39507 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752963AbYLCCL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:28 -0500
In-Reply-To: <1227780265.3809.55.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> > +/* Message types */
> > +enum i2400m_mt {
> > +	I2400M_MT_RESERVED              = 0x0000,
> > +	I2400M_MT_INVALID               = 0xffff,
 > ...
> > +	I2400M_MT_REPORT_EAP_RESTART    = 0xe003,
> > +	I2400M_MT_REPORT_ALT_ACCEPT    	= 0xe004,
> > +	I2400M_MT_REPORT_KEY_REQUEST 	= 0xe005,
>
> Since this is all device-specific, this is like implementing all of
> 802.11 management with iwpriv. 

No it is not -- management is done at the device level; disconnect WiFi, 
because this is completely different.

> Do you really want that? Why wouldn't most of these commands port 
> over to other hardware? 

As explained on the first message, vendors might choose to break the
hw interface at a different level. We won't force vendors to use the
same interface as the Intel device does or make the same design 
decisions we made.

-- 
Inaky

