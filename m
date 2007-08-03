From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] lro: eHEA example how to use LRO
Date: Fri, 03 Aug 2007 13:29:36 -0700
Message-ID: <46B39030.7030009@intel.com>
References: <200708031441.26841.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31365 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757152AbXHCU3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 16:29:38 -0400
In-Reply-To: <200708031441.26841.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> This patch shows how the generic LRO interface is used for SKB mode
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> 
> ---
>  drivers/net/Kconfig             |    1 +
>  drivers/net/ehea/ehea.h         |    9 ++++-
>  drivers/net/ehea/ehea_ethtool.c |   15 +++++++
>  drivers/net/ehea/ehea_main.c    |   84 +++++++++++++++++++++++++++++++++++---
>  4 files changed, 101 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f8a602c..fec4004 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig

<snip>

> +module_param(use_lro, int, 0);

Have you looked at my generic lro get/set patch that I posted this week? this 
adds a useless module parameter while ethtool has all the structure already to 
accomodate setting lro on/off.

Auke
