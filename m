From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/4][RFC] lro: Kconfig and Makefile
Date: Mon, 30 Jul 2007 10:00:30 -0700
Message-ID: <46AE192E.4080205@intel.com>
References: <200707301724.45781.ossthema@de.ibm.com> <20070730172535.15993806@oldman.hamilton.local> <46AE1383.3050305@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Andrew Gallatin <gallatin@myri.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49997 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965543AbXG3RBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 13:01:06 -0400
In-Reply-To: <46AE1383.3050305@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Stephen Hemminger wrote:
>> Why make this a user selectable option at all? Unless you want
>> to deal with out of tree drivers (not my problem), it should be hidden
>> to avoid having to explain an support it.
> 
> In this case it's an optional library kernel module.  That seems to be a 
> common setup for library modules.  We do the same with CONFIG_MII and 
> drivers/net/mii.ko as well.
> 
> Originally it was done purely in the Makefile, but that does not account 
> for net drivers in sub-directories (or out of tree as you point out).

speaking of that, shouldn't there be a NETIF_F_LRO ?

Auke
