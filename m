From: "Grandhi, Sainath" <sainath.grandhi@intel.com>
Subject: RE: [PATCH RFC v1 0/3] Support for tap user-space access with veth
 interfaces
Date: Mon, 9 Oct 2017 21:51:59 +0000
Message-ID: <2C5142675EC1274EAB6230F72F8DC95F6C106998@ORSMSX113.amr.corp.intel.com>
References: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:46553 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754506AbdJIVwB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 17:52:01 -0400
In-Reply-To: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
	Just a reminder for feedback. Please let me know your comments.

> -----Original Message-----
> From: Grandhi, Sainath
> Sent: Wednesday, September 06, 2017 5:34 PM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; Grandhi, Sainath <sainath.grandhi@intel.com>
> Subject: [PATCH RFC v1 0/3] Support for tap user-space access with veth
> interfaces
> 
> From: Sainath Grandhi <sainath.grandhi@intel.com>
> 
> This patchset adds a tap device driver for veth virtual network interface.
> With this implementation, tap character interface can be added only to the peer
> veth interface. Adding tap interface to veth is for usecases that forwards
> packets between host and VMs. This eliminates the need for an additional
> software bridge. This can be extended to create both the peer interfaces as tap
> interfaces. These patches are a step in that direction.
> 
> Sainath Grandhi (3):
>   net: Adding API to parse IFLA_LINKINFO attribute
>   net: Abstracting out common routines from veth for use by vethtap
>   vethtap: veth based tap driver
> 
>  drivers/net/Kconfig                 |   1 +
>  drivers/net/Makefile                |   2 +
>  drivers/net/{veth.c => veth_main.c} |  80 ++++++++++---
>  drivers/net/vethtap.c               | 216 ++++++++++++++++++++++++++++++++++++
>  include/linux/if_veth.h             |  13 +++
>  include/net/rtnetlink.h             |   3 +
>  net/core/rtnetlink.c                |   8 ++
>  7 files changed, 308 insertions(+), 15 deletions(-)  rename drivers/net/{veth.c =>
> veth_main.c} (89%)  create mode 100644 drivers/net/vethtap.c  create mode
> 100644 include/linux/if_veth.h
> 
> --
> 2.7.4
