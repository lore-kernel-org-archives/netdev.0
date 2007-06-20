From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiple queue hardware support
Date: Wed, 20 Jun 2007 10:21:00 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903111FA4@orsmsx414.amr.corp.intel.com>
References: <200706201658.43820.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>,
	"Christoph Raisch" <raisch@de.ibm.com>,
	"Thomas Klein" <osstklei@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>
To: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20633 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507AbXFTRVY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 13:21:24 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200706201658.43820.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> to me it seems that this patch set only include multiple 
> transmit queue support (for qdisc). Am I right with this 
> observation? If so, are there also plans to support multiple 
> receive queues to allow the queues to be processed in 
> parallel on different CPUs via a standard interface? 
> Currently, some drivers use "fake netdevices" to feed 
> netif_rx_schedule().
> 
> Thanks,
> Jan-Bernd

Jan,
	Yes, these patches are for transmit multiqueue hardware support
only.  There are other efforts to stop using the fake netdevices for Rx
polling, such as using MSI-X vectors assigned to particular receive
queues, but this is still done in the driver (which is ok).  I'm
currently not working on anything in the kernel to support multiqueue Rx
for non MSI-X devices though.

Thanks,
-PJ Waskiewicz
