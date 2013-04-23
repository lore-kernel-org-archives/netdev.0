From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/5] sock_diag: monitor packet sockets
Date: Tue, 23 Apr 2013 16:27:52 +0200
Message-ID: <1366727277-19522-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:52751 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab3DWO3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 10:29:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patchset is to be able to monitor packet sockets.
The two first patches add new attributes for packet_diag subsystem, so that all
information exported via the /proc/net/packet are also exported via netlink.
The third patch allows the user to get details about filter attached to a packet
socket.
Then, the two last one enable sockets monitoring. A netlink message is sent each
time a packet socket is created, deleted or when the filter information are
updated.

As usual, the patch against iproute2 will be sent once the patches are included and
net-next merged. I can send it on demand.
With this serie, the tools ss can monitor packet sockets activity.

 include/linux/sock_diag.h        |  4 +++
 include/uapi/linux/packet_diag.h |  5 +++
 include/uapi/linux/sock_diag.h   | 13 +++++++-
 net/core/filter.c                |  3 ++
 net/core/sock_diag.c             | 68 ++++++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c           |  4 +++
 net/packet/diag.c                | 49 +++++++++++++++++++++++++----
 7 files changed, 139 insertions(+), 7 deletions(-)

Comments are welcome.

Regards,
Nicolas
