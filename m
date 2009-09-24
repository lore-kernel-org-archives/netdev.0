From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ems_pci: fix size of CAN controllers BAR mapping
 for CPC-PCI v2
Date: Thu, 24 Sep 2009 15:46:44 -0700 (PDT)
Message-ID: <20090924.154644.104454662.davem@davemloft.net>
References: <20090924135505.13453.61811.stgit@localhost.localdomain>
	<4ABB7F63.2000108@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haas@ems-wuensche.com, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202AbZIXWqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 18:46:25 -0400
In-Reply-To: <4ABB7F63.2000108@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 24 Sep 2009 16:17:07 +0200

> Sebastian Haas wrote:
>> The driver mapped only 128 bytes of the CAN controller address space when a
>> CPC-PCI v2 was detected (incl. CPC-104P). This patch will fix it by always
>> mapping the whole address space (4096 bytes on all boards) of the
>> corresponding PCI BAR.
>> 
>> Signed-off-by: Sebastian Haas <haas@ems-wuensche.com>
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied.
