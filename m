From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: FW: [PATCH v5 ethtool 0/2] patchset - Support for configurable RSS
 hash key
Date: Tue, 6 May 2014 08:26:44 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C8BC00E@CMEXMB1.ad.emulex.com>
References: <501b590b-178c-4c69-b82b-e7cfa96276ef@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings (ben@decadent.org.uk)" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:56896 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934235AbaEFI0q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 04:26:46 -0400
In-Reply-To: <501b590b-178c-4c69-b82b-e7cfa96276ef@CMEXHTCAS2.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please look into this. Thanks.

Venkat.

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Venkat Duvvuru
Sent: Monday, April 21, 2014 3:39 PM
To: netdev@vger.kernel.org
Cc: Venkata Duvvuru
Subject: [PATCH v5 ethtool 0/2] patchset - Support for configurable RSS hash key

NIC drivers that support RSS use either a hard-coded value or a random value for the RSS hash key. Irrespective of the type of the key used, the user would want to change the hash key if he/she is not satisfied with the effectiveness of the default hash-key in spreading the incoming flows evenly across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the ethtool interface using .X/-x option.

v5:
1. Added rss_context field to ethtool_rxfh structure to support multiple
   rss contexts.

Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key
  ethtool: Support for configurable RSS hash key

 ethtool-copy.h |   34 +++++++-
 ethtool.8.in   |   18 +++--
 ethtool.c      |  253 ++++++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 244 insertions(+), 61 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
