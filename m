From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 0/3] make skb_checksum_setup generally available
Date: Wed, 8 Jan 2014 13:58:28 +0000
Message-ID: <1389189511-14568-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63640 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860AbaAHN6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 08:58:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both xen-netfront and xen-netback need to be able to set up the partial
checksum offset of an skb and may also need to recalculate the pseudo-
header checksum in the process. This functionality is currently private
and duplicated between the two drivers.

Patch #1 of this series moves the implementation into the core network code
as there is nothing xen-specific about it and it is potentially useful to
any network driver.
Patch #2 removes the private implementation from netback.
Patch #3 removes the private implementation from netfront.
