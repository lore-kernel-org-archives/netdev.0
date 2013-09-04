From: "Ariel Elior" <ariele@broadcom.com>
Subject: bnx2x: VF RSS support
Date: Wed, 4 Sep 2013 14:09:20 +0300
Message-ID: <1378292962-5537-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4733 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753625Ab3IDLIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 07:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series adds the capability for VF functions to use multiple queues
and Receive / Transmit side scaling.

Patch #1 enhances the PF's side database to allow for multiple queues per PF
and configure the HW appropriately, and the PF side of the VF PF channel
message for configuring the RSS.

Patch #2 adds to the VF side the ability to request multiple queues, and if
obtained to configure RSS for them over the VF PF channel.

Thanks,
Ariel Elior
