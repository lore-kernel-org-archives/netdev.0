From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 52/72] ps3_gelic*: Move the Sony (PS3) drivers
Date: Sat, 25 Jun 2011 16:54:53 +0200
Message-ID: <201106251654.53606.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-53-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Geoff Levand <geoff@infradead.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:62629 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab1FYOzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:55:04 -0400
In-Reply-To: <1309010363-22750-53-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Jeff Kirsher wrote:
> 
> Move the Sony drivers into drivers/net/ethernet/sony/ and
> make the necessary Kconfig and Makefile changes.
> 
> TODO: separate the wired and wireless drivers and relocate the wireless
> dirver into drivers/net/wireless/
> 
> CC: Geoff Levand <geoff@infradead.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

This one is the same hardware as spider_net, just with the PS3 hypervisor
layer inbetween. I'd suggest moving that to a Toshiba directory as well.

	Arnd
