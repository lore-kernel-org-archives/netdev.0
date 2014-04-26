From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2] Use IPv6 flow labels for ECMP hash
Date: Sat, 26 Apr 2014 16:00:08 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261552530.15723@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:47080 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbaDZXAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 19:00:10 -0400
Received: by mail-qa0-f74.google.com with SMTP id w8so819738qac.5
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 16:00:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets implements use of IPv6 flow label to provide a
network hash for ECMP (RFC 6438). On the RX side, flow_dissector is
fixed to accept a non-zero flow label as a substitue for L4
port information. On transmit side, we set the flow label to the
flow hash of a packet. This implementation should be consistent
with section 3 of RFC 6437 (Flow Labeling Requirements in the Stateless
Scenario).
