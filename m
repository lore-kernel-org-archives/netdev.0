From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/2] packet fix
Date: Fri,  6 Nov 2015 22:02:40 +0100
Message-ID: <cover.1446842228.git.daniel@iogearbox.net>
Cc: davem@davemloft.net, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55341 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965993AbbKFVCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 16:02:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

does this resolve the issues you're having on the TX_RING when dealing
with trafgen [1]?

Thanks a lot,
Daniel

  [1] http://thread.gmane.org/gmane.linux.network/385988

Daniel Borkmann (2):
  packet: do skb_probe_transport_header when we actually have data
  packet: fix tpacket_snd max frame and vlan handling

 net/packet/af_packet.c | 106 ++++++++++++++++++++++++++++++-------------------
 1 file changed, 66 insertions(+), 40 deletions(-)

-- 
1.9.3
