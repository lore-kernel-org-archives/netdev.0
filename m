From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2 0/4] xen-netback: support for control ring
Date: Wed, 11 May 2016 16:16:26 +0100
Message-ID: <1462979790-2824-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>
To: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:2034 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932093AbcEKPaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 11:30:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My recent patch to import an up-to-date include/xen/interface/io/netif.h
from the Xen Project brought in the necessary definitions to support the
new control shared ring and protocol. This patch series updates xen-netback
to support the new ring.

Patch #1 adds the necessary boilerplate to map the control ring and handle
messages. No implementation of the new protocol is included in this patch
so that it can be kept to a reasonable size.

Patch #2 adds the protocol implementation.

Patch #3 adds support for passing has values calculated by xen-netback to
capable frontends.

Patch #4 adds support for accepting hash values calculated by capable
frontends and using them the set the socket buffer hash.
