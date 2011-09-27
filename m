From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 4/7] bna: Brocade 1860 HW Enablement
Date: Tue, 27 Sep 2011 00:41:53 -0400 (EDT)
Message-ID: <20110927.004153.558055626011624681.davem@davemloft.net>
References: <1317071541-9662-1-git-send-email-rmody@brocade.com>
	<1317071541-9662-5-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	gkaraje@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826Ab1I0Em4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 00:42:56 -0400
In-Reply-To: <1317071541-9662-5-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Mon, 26 Sep 2011 14:12:18 -0700

>  include/linux/pci_ids.h                        |    1 +

Please do not add new PCI device ID entries to linux/pci_ids.h
for use by a single device driver.

That header is only used when the PCI device ID will be used in
multiple drivers (such as network + iSCSI as some of the broadcom
drivers are).
