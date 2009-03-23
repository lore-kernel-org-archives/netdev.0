From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: ucc_geth: nf_conntrack: table full, dropping packet.
Date: Mon, 23 Mar 2009 11:42:20 +0100
Message-ID: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: netdev@vger.kernel.org, avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:56753 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115AbZCWKmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 06:42:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

doing a "ping -f -l 3" on my host towards my board on linus tree as of 
Friday results in lots of:
nf_conntrack: table full, dropping packet.
nf_conntrack: table full, dropping packet.
nf_conntrack: table full, dropping packet.
__ratelimit: 11 callbacks suppressed
nf_conntrack: table full, dropping packet.
nf_conntrack: table full, dropping packet.
nf_conntrack: table full, dropping packet.
nf_conntrack: table full, dropping packet.

for ucc_geth on a MPC832x.
This really looks strange to me, ideas?

 Jocke
