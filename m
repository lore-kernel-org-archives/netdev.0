From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 0/3] net: use rx_handler_data pointer for bridge
 and macvlan ports
Date: Thu, 10 Jun 2010 15:34:12 +0200
Message-ID: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@vyatta.com, kaber@trash.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64280 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758287Ab0FJNeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 09:34:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since recent changes ensured that only one rx_handler can be present at a time,
always either macvlan_port or br_port pointer in net_device structure is
not used. So introduce rx_handler_data pointer into net_device structure to
store this data pointer and safe some space. Also this pointer is right next
rx_handler pointer most likely on the same cache line.

Jirka
