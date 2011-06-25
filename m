From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC 18/72] ehea/ibm*: Move the IBM drivers
Date: Sat, 25 Jun 2011 16:39:28 +0200
Message-ID: <4E05F320.1080202@hartkopp.net>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-19-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Christoph Raisch <raisch@de.ibm.com>,
	Alfred Arnold <alfred.arnold@lancom.de>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:12141 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab1FYOjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:39:43 -0400
In-Reply-To: <1309010363-22750-19-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.06.2011 15:58, Jeff Kirsher wrote:
> Move the IBM drivers into drivers/net/ethernet/ibm/ and make the
> necessary Kconfig and Makefile changes.

(..)

>  drivers/net/{ => ethernet/ibm}/ibm_newemac/Kconfig |    2 +-
>  .../net/{ => ethernet/ibm}/ibm_newemac/Makefile    |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/core.c  |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/core.h  |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.c |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.h |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/emac.h  |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.c   |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.h   |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.c   |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.h   |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.c |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.h |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.c   |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.h   |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.c  |    0
>  drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.h  |    0

s/ibm_newemac/newemac/

as it is already inside a directory called ibm?

>  drivers/net/{ => ethernet/ibm}/ibmlana.c           |    0
>  drivers/net/{ => ethernet/ibm}/ibmlana.h           |    0
>  drivers/net/{ => ethernet/ibm}/ibmveth.c           |    0
>  drivers/net/{ => ethernet/ibm}/ibmveth.h           |    0

Maybe in these c/h files the 'ibm' could be removed too?

Regards,
Oliver

btw: Thanks for the cleanup. Great work!
