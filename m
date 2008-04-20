From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Expose netdevice dev_id through sysfs
Date: Sat, 19 Apr 2008 22:32:41 -0700 (PDT)
Message-ID: <20080419.223241.252348841.davem@davemloft.net>
References: <1208176322.31695.73.camel@pmac.infradead.org>
	<20080419.183341.46125500.davem@davemloft.net>
	<200804200921.09072.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-hotplug@vger.kernel.org, dwmw2@infradead.org,
	kay.sievers@vrfy.org, md@linux.it, harald@redhat.com,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com
To: arvidjaar@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37605
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbYDTFcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 01:32:39 -0400
In-Reply-To: <200804200921.09072.arvidjaar@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Borzenkov <arvidjaar@mail.ru>
Date: Sun, 20 Apr 2008 09:21:03 +0400

> On Sparc system we also have global device tree which provides unique
> and persistent reference to every device. Solaris has no problems with
> having same MAC for all interfaces.

SunOS/Solaris names devices geographically on the I/O bus.  So if you
move the card from one slot to another, it's a different device and
you have to change your configuration, which is pretty bogus.

At least under Linux the identity follows the MAC address, which I
definitely see as a superior behavior.

The only problem is handling the multiple devices with same MAC case.

> What is exactly wrong with using device topology path? This should
> exist on any system, it is unique and it is persistent.

Because if you move the device to a different PCI slot it should
still show up as the same device, using the MAC address as the key.
The Solaris behavior isn't so intelligent.
