From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: e1000 driver and samba
Date: Fri, 14 Sep 2007 20:26:45 +0200
Message-ID: <20070914182645.GA22975@electric-eye.fr.zoreil.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: L F <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42746 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755372AbXINS3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:29:46 -0400
Content-Disposition: inline
In-Reply-To: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L F <lfabio.linux@gmail.com> :
[...]
> Now, the machine worked when it was using an onboard Realtek 8169
> chipset on a 945G board from ASUS, but it worked slowly. I upgraded to
> a P965 chipset, started using the realtek driver for the 8110B on that
> board.. and started getting consistent samba errors. I therefore
> killed the onboard LAN, switched to the Intel board, tried both the
> 7.6.5 driver on the Intel website AND the driver in the 2.6.20+
> kernels - 7.2.x IIRC - and it fails, less than it did with the
> realtek, but it fails. Switching back and forth between 2.6.18,
> 2.6.20.x and 2.6.22.x yielded no improvements. I could use some help,
> because I refuse to believe that there isn't a reliable PCIexpress
> gigeth/samba combo available.
> For further reference, the kernel versions are those mentioned above,
> compiled with gcc-3.4.6 and gcc-4.1.2 (current on debian-testing),
> with no improvement between the two.
> Any and all indications appreciated.

For the 8169 or the 8110, try 2.6.23-rc6 +

http://www.fr.zoreil.com/people/francois/misc/20070903-2.6.23-rc5-r8169-test.patch

-- 
Ueimor
