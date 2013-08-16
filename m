From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH] net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions
 for re-use
Date: Fri, 16 Aug 2013 15:51:10 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1308161550050.24009@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307101425310.22696@eeeadesso> <0cbf7c81-182e-493c-9c28-5b78160a08f1@email.android.com> <alpine.LNX.2.02.1307170457450.1161@eeeadesso> <87bo4xx3ef.fsf@nemi.mork.no>
 <alpine.LNX.2.02.1308161534410.23935@eeeadesso> <20130816134907.GA10987@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:54449 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735Ab3HPNuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 09:50:44 -0400
In-Reply-To: <20130816134907.GA10987@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, you're right. I'm sorry - this time I didn't apply numbering scheme to 
those 3 patches - yet they are consequential, but not depending on each other 
from a strict point of view.

Thank you for your review Greg!


On Fri, 16 Aug 2013, Greg Kroah-Hartman wrote:

==Date: Fri, 16 Aug 2013 06:49:07 -0700
==From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: Bj?rn Mork <bjorn@mork.no>, linux-kernel@vger.kernel.org,
==    linux-usb@vger.kernel.org, netdev@vger.kernel.org
==Subject: Re: [PATCH] net: cdc_ncm: Export cdc_ncm_{tx,
==    rx}_fixup functions for re-use
==
==On Fri, Aug 16, 2013 at 03:39:19PM +0200, Enrico Mioso wrote:
==> Some drivers implementing NCM-like protocols, may re-use those functions, as is 
==> the case in the huawei_cdc_ncm driver.
==
==Where is that driver at, I don't see it in the kernel tree.
==
==> Export them via EXPORT_SYMBOL_GPL.
==
==Normally we don't export symbols until code that actually uses the
==symbols lands in the tree at the same time.
==
==thanks,
==
==greg k-h
==
