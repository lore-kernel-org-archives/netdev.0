From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 55/72] bfin_mac: Move the Blackfin driver
Date: Sat, 25 Jun 2011 16:57:36 +0200
Message-ID: <201106251657.36501.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-56-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Michael Hennerich <michael.hennerich@analog.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56255 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab1FYO5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:57:40 -0400
In-Reply-To: <1309010363-22750-56-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Jeff Kirsher wrote:
> 
> Move the Blackfin driver into drivers/net/ethernet/blackfin/ and
> make the necessary Kconfig and Makefile changes.
> 
> CC: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS                                    |    2 +-
>  drivers/net/Kconfig                            |   46 -----------------
>  drivers/net/Makefile                           |    1 -
>  drivers/net/ethernet/Kconfig                   |    1 +
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/ethernet/blackfin/Kconfig          |   65 ++++++++++++++++++++++++
>  drivers/net/ethernet/blackfin/Makefile         |    5 ++
>  drivers/net/{ => ethernet/blackfin}/bfin_mac.c |    0
>  drivers/net/{ => ethernet/blackfin}/bfin_mac.h |    0

Since you are sorting by company, I'd suggest making the directory
analog, not blackfin, which is just the CPU architecture.

	Arnd
