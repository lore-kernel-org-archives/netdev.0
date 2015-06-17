From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net 0/2] bridge: multicast behaviour fixes
Date: Wed, 17 Jun 2015 04:28:29 -0700
Message-ID: <1434540511-648-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, sashok@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34002 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbbFQL25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 07:28:57 -0400
Received: by pdbki1 with SMTP id ki1so37753061pdb.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 04:28:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Patch 01 fixes a problem when a router is configured and a port goes
through a link down/up, the router configuration was not restored.
Patch 02 starts the multicast querier when using user-space STP and a
port goes to forwarding state.
These are behaviour fixes and if you think they are more appropriate for
net-next, then feel free to apply them there, I've run them with both
net and net-next. Also I've provided "fixes" tags, but since these are
behaviour changes they're the initial implementations of these functions.

Best regards,
 Nikolay Aleksandrov

Satish Ashok (2):
  bridge: multicast: restore router configuration on port link down/up
  bridge: multicast: start querier timer when running user-space stp

 net/bridge/br_multicast.c | 4 ++++
 net/bridge/br_stp.c       | 3 +++
 2 files changed, 7 insertions(+)

-- 
2.4.3
