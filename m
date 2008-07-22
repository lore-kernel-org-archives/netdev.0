From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESENDv2 01/11] netxen: cleanup unused variables/functions
Date: Tue, 22 Jul 2008 18:01:21 -0400
Message-ID: <488658B1.9040505@garzik.org>
References: <> <1216694650-23257-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53250 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782AbYGVWBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 18:01:24 -0400
In-Reply-To: <1216694650-23257-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> o Reduce access to global arrays in data path.
> o Remove duplicate/unused variables, unecessary alignment constraints.
> o Use correct pci_dev instead of fallback device for consistent
>   allocations.
> o Disable ethtool set_eeprom functionality for now, it was only used
>   for flashing firmware.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic.h          |   19 +--
>  drivers/net/netxen/netxen_nic_ethtool.c  |    5 +-
>  drivers/net/netxen/netxen_nic_hw.c       |  270 +++++++-----------------------
>  drivers/net/netxen/netxen_nic_init.c     |   88 +++-------
>  drivers/net/netxen/netxen_nic_main.c     |   74 ++-------
>  drivers/net/netxen/netxen_nic_phan_reg.h |   17 +--
>  6 files changed, 113 insertions(+), 360 deletions(-)

applied 1-11

