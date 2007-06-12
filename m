From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 17:13:54 -0400
Message-ID: <466F0C92.5080306@garzik.org>
References: <466DEF9D.9070509@trash.net>	<1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net> <20070612.140240.00078635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58251 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbXFLVN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 17:13:59 -0400
In-Reply-To: <20070612.140240.00078635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


If hardware w/ multiple queues will the capability for different MAC 
addresses, different RX filters, etc. does it make sense to add that 
below the net_device level?

We will have to add all the configuration machinery at the per-queue 
level that already exists at the per-netdev level.

	Jeff



