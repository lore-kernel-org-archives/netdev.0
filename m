From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: [PATCH ethtool] Display adjacent switch port's attributes
Date: Wed, 11 Dec 2013 14:32:27 +0100
Message-ID: <1386768748-57530-1-git-send-email-raspl@linux.vnet.ibm.com>
Cc: davem@davemloft.net, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:54840 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636Ab3LKNe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 08:34:29 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 13:34:28 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new option to ethtool to display the adjacent switch
port's attributes, as perceived by the NIC, e.g. through respective LLDP
message exchanges.

Best regards,
Stefan Raspl

Stefan Raspl (1):
  ethtool: Add option '-q' to display adjacent switch port's attributes

 ethtool-copy.h | 35 ++++++++++++++++++++++++++++++
 ethtool.8.in   |  6 ++++++
 ethtool.c      | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 109 insertions(+)

-- 
1.8.3.4
