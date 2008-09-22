From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: OOPS bug KERNEL LINUX- Version 2.6.26
Date: Tue, 23 Sep 2008 00:32:36 +0200
Message-ID: <200809230032.37255.IvDoorn@gmail.com>
References: <K7M9ZI$69A44BBF23D86D612A80B0EA98EEEE6B@libero.it> <200809230025.03680.IvDoorn@gmail.com> <20080922222716.GI3660@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andrea_monta@inwind.it,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, stable@kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:35605 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbYIVWcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 18:32:42 -0400
Received: by ik-out-1112.google.com with SMTP id c30so1019085ika.5
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 15:32:40 -0700 (PDT)
In-Reply-To: <20080922222716.GI3660@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 September 2008, John W. Linville wrote:
> On Tue, Sep 23, 2008 at 12:25:03AM +0200, Ivo van Doorn wrote:
> > Hi,
> > 
> > > > 1. Problem with usb-wireless-key 
> > > > 2. I can't find my device typing ifconfig -a or iwconfig I don't find any wireless attached device. But I have my usb wireless connected. A belkin usb wireless key.Before, with the kernel 2.6.25 all worked well
> > > > 3. nothing
> > > > 4. Linux version 2.6.26 (root@clementino) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 PREEMPT Mon Sep 22 15:57:45 CEST 2008
> > > > 5.
> > 
> > You missed the message from rt2x00 2 lines above this trace, which undoubtly have said something like:
> > 	"Invalid RT chipset detected."
> > which is triggered when rt73usb is loaded for a device it does not support
> > 
> > The current workaround for this issue is blacklisting rt73usb and making sure the driver
> > which is required for your driver is loaded instead.
> > 
> > I'll look into the reason why this actually triggers a NULL pointer, since that is obviously a nasty bug.
> 
> -stable needs a patch similar to the one here:
> 
> 	http://people.redhat.com/linville/kernels/rhel5/patches/jwltest-rt2x00lib-probe-fail.patch

Ah yes, that would be a good one.
I kind of assumed it was already merged, and hadn't actually verified that yet. ;)

Ivo


