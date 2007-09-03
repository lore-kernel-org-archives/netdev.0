From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: jumbo frames
Date: Mon, 3 Sep 2007 22:57:56 +0200
Message-ID: <20070903205756.GA4444@electric-eye.fr.zoreil.com>
References: <20070902165904.GA11650@csy.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Shane <shane@csy.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51446 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752939AbXICVBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 17:01:38 -0400
Content-Disposition: inline
In-Reply-To: <20070902165904.GA11650@csy.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shane <shane@csy.ca> :
[...]
> Just wanted to report that when setting a mtu of 4074, I'm
> getting slow Samba performance with an r8169 based NIC even
> with the fix for this posted here applied.  all dmesg shows
> is:
> NETDEV WATCHDOG: eth0: transmit timed out

It is a bit terse:
- which kernel ?
- which fix exactly (Message-Id or URL) ? The one I sent the
  29 of 08/2007 or something else ?
- which chipset (lspci -vvx) ?

Fwiw, I have rediffed the patchkit against 2.6.23-rc5. See:
http://www.fr.zoreil.com/people/francois/misc/20070903-2.6.23-rc5-r8169-test.patch
or:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.23-rc5/r8169-20070903/

If you have not done so already, I would appreciate that you try
to reproduce the problem with a 1500 bytes MTU with/without the
aforementioned patch.

> The mtu value is due to Windows workstations which support
> this value and 9k MTU but the r8169 doesn't appear to like
> 9k although that's where I'd like it to be on this network.

The 8169 will not fly above 7200, be it on Linux or Windows. :o/

-- 
Ueimor
