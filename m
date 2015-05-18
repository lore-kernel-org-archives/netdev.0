From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/8] s390: network patches for net-next
Date: Mon, 18 May 2015 14:27:51 +0200
Message-ID: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:46926 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbbERM2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:28:11 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 18 May 2015 13:28:10 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

here are s390 related patches for net-next

shortlog:

Thomas Richter (1)
  qeth: fix rx checksum offload handling

Eugene Crosser (6)
  qeth: fix handling of IPA return codes
  qeth: remove locks from sysfs _show
  qeth: reflect IFF_PROMISC flag to BRIDGE PORT mode
  qeth: OSA version of SETBRIDGEPORT command message
  qeth: BRIDGEPORT "sanity check"
  qeth: replace ENOSYS with EOPNOTSUPP

Peter Oberparleitner (1)
  lcs: Fix null-pointer access in msg

Thanks,
       Ursula
