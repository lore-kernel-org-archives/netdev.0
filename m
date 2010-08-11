From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 12:11:52 +0200
Message-ID: <AANLkTimX46QKAGhiyo8AodaXVjuzoxr5-5z2V4gRr1Vu@mail.gmail.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>
	<20100811095454.GA22543@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:59268 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932927Ab0HKKL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 06:11:56 -0400
In-Reply-To: <20100811095454.GA22543@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You haven't said what HCD you're using.
>
imx21_hcd  (submitted by me and mainlined in 2.6.34)

> In that case, I'd say the HCD must handle misaligned URBs itself so
> behaviour is consistent between all implementations on different
> platforms.
>
Here is a pointer to the thread where it was stated that HCD's don't
have to handle this.

http://kerneltrap.org/mailarchive/linux-usb/2009/4/20/5528164
