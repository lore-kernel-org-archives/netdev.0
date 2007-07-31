From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCHES] RFC: Ethtool patches to add multi queue support, LRO
Date: Tue, 31 Jul 2007 13:20:23 -0700
Message-ID: <46AF9987.3060007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51501 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759329AbXGaUUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 16:20:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


All,

Recently new features have been written to add multiqueue support and LRO. 
However, none of the patches touch on a basic configuration scheme and most use 
module parameters.

I propose several patches to add support to change these features for LRO and 
multiqueue. Currently these patches are implemented in the most generic way 
possible (largely copy/paste from current ethtool code) - and add 'ethtool -k 
lro on|off' support that toggles the NETIF_F_LRO generic device flag, and a new 
ethtool_queueparam struct to get/pass rx and tx queue count.

I'm contenplating adding a "usecs-irq" non-rx non-tx parameter for the intel 
(1/10) gigabit adapters since our adapters share an interrupt moderation 
counters for both rx and tx, but that will come later.


Cheers,

Auke
