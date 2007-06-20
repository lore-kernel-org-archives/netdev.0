From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: RE: [PATCH] NET: Multiple queue hardware support
Date: Wed, 20 Jun 2007 16:58:43 +0200
Message-ID: <200706201658.43820.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:42735 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175AbXFTPWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 11:22:08 -0400
Received: from d12nrmr1507.megacenter.de.ibm.com (d12nrmr1507.megacenter.de.ibm.com [9.149.167.1])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5KFM7Ft039056
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 15:22:07 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1507.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KFM6YM1474762
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 17:22:06 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KFM6xh008708
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 17:22:06 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

to me it seems that this patch set only include multiple transmit queue support
(for qdisc). Am I right with this observation? If so, are there also plans to 
support multiple receive queues to allow the queues to be processed in parallel
on different CPUs via a standard interface? Currently, some drivers use 
"fake netdevices" to feed netif_rx_schedule().

Thanks,
Jan-Bernd
