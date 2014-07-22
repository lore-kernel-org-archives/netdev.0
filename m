From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 05/10] net: Add Geneve tunneling protocol driver
Date: Tue, 22 Jul 2014 16:12:27 -0700
Message-ID: <53CEEFDB.5030900@intel.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com> <1406024393-6778-6-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Andy Zhou <azhou@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15074 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757135AbaGVXM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 19:12:28 -0400
In-Reply-To: <1406024393-6778-6-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 03:19 AM, Andy Zhou wrote:
> This adds a device level support for Geneve -- Generic Network
> Virtualization Encapsulation. The protocol is documented at
> http://tools.ietf.org/html/draft-gross-geneve-00
> 
> Only protocol layer Geneve support is provided by this driver.
> Openvswitch can be used for configuring, set up and tear down
> functional Geneve tunnels.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---
>  include/net/geneve.h     |   85 +++++++++++++++
>  include/net/ip_tunnels.h |    2 +
>  net/ipv4/Kconfig         |   14 +++
>  net/ipv4/Makefile        |    1 +
>  net/ipv4/geneve.c        |  273 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/Kconfig  |   11 ++
>  net/openvswitch/vport.c  |    3 +
>  7 files changed, 389 insertions(+)
>  create mode 100644 include/net/geneve.h
>  create mode 100644 net/ipv4/geneve.c
> 

So all this is really doing is enabling a Geneve socket for use by
Openvswitch.  Do you have any plans to enable a stand alone interface
like what we already have for VXLAN?

Thanks,

Alex
