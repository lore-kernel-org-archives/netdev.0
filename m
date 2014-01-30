From: Mark Lord <mlord@pobox.com>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Thu, 30 Jan 2014 14:45:36 -0500
Message-ID: <52EAABE0.8000904@pobox.com>
References: <22081260.RNay0J72dY@athas> <20140129215408.GC5991@xanatos> <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com> <20140130184412.GA3787@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "renevant@internode.on.net" <renevant@internode.on.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:57817 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbaA3Tq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 14:46:26 -0500
In-Reply-To: <20140130184412.GA3787@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-01-30 01:44 PM, Sarah Sharp wrote:
..
> Since the USB ethernet scatter-gather support wasn't added until the
> 3.12 kernel, it's unlikely that the xHCI TD fragment issue is actually
> the root cause.
> 
> The interesting piece of information in that report is that when the USB
> 3.0 device falls back to USB 2.0 speeds under xHCI, it works.

Could be due to something related to the max URB length:

USB 2.0 High-Speed: max URB length 512.
USB 3.0 Super-Speed: max URB length 1024.

Cheers
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
