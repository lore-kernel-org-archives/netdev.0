From: raspl@linux.vnet.ibm.com
Subject: [PATCH ethtool 0/3] Display adjacent switch port's attributes
Date: Mon, 09 Dec 2013 07:31:54 +0100
Message-ID: <20131209063154.508075549@linux.vnet.ibm.com>
Cc: davem@davemloft.net, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:60369 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464Ab3LLIdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 03:33:09 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 08:33:07 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a new option to ethtool to display the adjacent switch
port's attributes, as perceived by the NIC, e.g. through respective LLDP
message exchanges.
A patch for the qeth device driver provides a sample exploiter for the new
functionality.

Best regards,
Stefan Raspl
