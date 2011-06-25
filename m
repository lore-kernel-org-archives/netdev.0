From: Geoff Levand <geoff@infradead.org>
Subject: Re: [RFC 52/72] ps3_gelic*: Move the Sony (PS3) drivers
Date: Sat, 25 Jun 2011 09:25:02 -0700
Message-ID: <4E060BDE.9020004@infradead.org>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-53-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:46512
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751581Ab1FYQZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 12:25:03 -0400
In-Reply-To: <1309010363-22750-53-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

On 06/25/2011 06:59 AM, Jeff Kirsher wrote:
> Move the Sony drivers into drivers/net/ethernet/sony/ and
> make the necessary Kconfig and Makefile changes.

This looks OK, but as Arnd mentioned, it makes sense to put these
with the toshiba spider_net drivers.

> TODO: separate the wired and wireless drivers and relocate the wireless
> dirver into drivers/net/wireless/

I'm not sure if it makes sense to split this into separate drivers.

The PS3 doesn't have separate wireless and Ethernet devices.  The wireless
hardware is hooked up to the gelic Ethernet controller, and VLAN tags are
used to route the packets.  The wireless support is more or less
an extension of the base gelic device. 

A little more info on it is here:

  http://www.kernel.org/pub/linux/kernel/people/geoff/cell/ps3-linux-docs/ps3-linux-docs-latest/LinuxKernelOverview.html

Let me know what you think.

-Geoff
