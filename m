From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Thu, 19 Jun 2008 02:59:19 -0700
Message-ID: <20080619095919.cf02dbe3@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sam Ravnborg" <sam@ravnborg.org>, jeff@garzik.org,
	netdev@vger.kernel.org, sathyap@serverengines.com
To: "Christoph Hellwig" <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:56374 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939AbYFSJ7X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 05:59:23 -0400
In-Reply-To: 20080619091135.GA11101@infradead.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph,

The primary reason for separating the lower layer
code from rest of the driver is to share it
across two drivers for the two functions
of the device.  The secondary objective of
keeping this code OS neutral through 
abstractions has been conceded based
on the review comments from the last few 
rounds.

Thanks.

Subbu

----- Original Message -----
From: Christoph Hellwig [mailto:hch@infradead.org]
To: Subbu Seetharaman [mailto:subbus@serverengines.com]
Cc: Sam Ravnborg [mailto:sam@ravnborg.org], jeff@garzik.org, netdev@vger.kernel.org, sathyap@serverengines.com
Sent: Thu, 19 Jun 2008 02:11:35 -0700
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile


On Wed, Jun 18, 2008 at 11:27:01PM -0700, Subbu Seetharaman wrote:
> We could not get KBUILD_EXTRA_SYMBOLS to work.
> This  is what we did :
> 
> beclib's Module.symvers has entries like this :
> 
> 0x00000000      be_eq_destroy   /home/subbu/kod39-sperla/drivers/message/beclib/beclib  EXPORT_SYMBOL 
> 
> benet uses exports from beclib and we have the following line in benet's Makefile: 
> KBUILD_EXTRA_SYMBOLS = $(src)/../../message/beclib/Module.symvers 
> 
> When we build benet we still get warnings like this
> for symbols defined and exported from beclib :
> WARNING: "be_eq_destroy" [/home/subbu/kod39-sperla/drivers/net/benet/benet.ko] undefined! 
> 


The righ answer is of course to kill all this beclib junk and write
a proper linux driver.  We're made it pretty clear a few times in the
past that these abstraction layers don't go in.

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

