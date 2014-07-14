From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/4] udp: UDP tunnel enhancements
Date: Sun, 13 Jul 2014 19:49:29 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407131942580.25072@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:50853 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaGNCtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 22:49:31 -0400
Received: by mail-ob0-f201.google.com with SMTP id nu7so738109obb.4
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 19:49:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Add udp_sock_create in new helper module udp_tunnel. Tunnel
  implementations call this function to create listener UDP ports.
- Make vxlan and l2tp call udp_sock_create.
- Move udp_tunnel_segment into udp_offload.c.
