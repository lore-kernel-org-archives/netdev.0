From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 0/3] packet fixes
Date: Tue, 10 Nov 2015 23:03:02 +0100
Message-ID: <cover.1447191361.git.daniel@iogearbox.net>
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33137 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbKJWDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 17:03:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a couple of issues in packet sockets, i.e. on TX ring side. See
individual patches for details.

v1 -> v2:
 - Added patch 2 as suggested by Dave
 - Rest is unchanged from previous submission

Daniel Borkmann (3):
  packet: do skb_probe_transport_header when we actually have data
  packet: always probe for transport header
  packet: fix tpacket_snd max frame and vlan handling

 net/packet/af_packet.c | 109 ++++++++++++++++++++++++++++++-------------------
 1 file changed, 67 insertions(+), 42 deletions(-)

-- 
1.9.3
