From: raspl@linux.vnet.ibm.com
Subject: [PATCH ethtool 0/3] Display adjacent switch port's attributes
Date: Mon, 09 Dec 2013 09:11:40 +0100
Message-ID: <20131209081140.196136547@linux.vnet.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-s390 <linux-s390@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:52468 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab3LLIdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 03:33:11 -0500
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 08:33:08 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a new option to ethtool to display the adjacent switch
port's attributes, as perceived by the NIC, e.g. through respective LLDP
message exchanges.
A patch for the qeth device driver provides a sample exploiter for the new
functionality.

Best regards,
Stefan Raspl
