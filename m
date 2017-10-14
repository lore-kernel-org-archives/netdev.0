From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 0/2] net: add skb_memcpy_to[from]_msg()
Date: Sat, 14 Oct 2017 10:25:55 +0800
Message-ID: <1507947955-4674-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:50285 "EHLO m12-11.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752769AbdJNC0b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 22:26:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>



yuan linyu (2):
  net: move memcpy_to[from]_msg() from skbuff.h to socket.h
  net: add skb_memcpy_to[from]_msg() to optimize skb code

 drivers/isdn/mISDN/socket.c        |  2 +-
 drivers/staging/irda/net/af_irda.c |  2 +-
 include/linux/skbuff.h             |  8 ++++----
 include/linux/socket.h             | 12 +++++++++++-
 net/appletalk/ddp.c                |  2 +-
 net/ax25/af_ax25.c                 |  2 +-
 net/bluetooth/hci_sock.c           |  4 ++--
 net/bluetooth/rfcomm/sock.c        |  2 +-
 net/bluetooth/sco.c                |  2 +-
 net/caif/caif_socket.c             |  6 +++---
 net/can/bcm.c                      |  4 ++--
 net/can/raw.c                      |  4 ++--
 net/dccp/proto.c                   |  2 +-
 net/decnet/af_decnet.c             |  4 ++--
 net/ieee802154/socket.c            |  4 ++--
 net/ipx/ipx_route.c                |  2 +-
 net/key/af_key.c                   |  2 +-
 net/l2tp/l2tp_ip.c                 |  2 +-
 net/l2tp/l2tp_ppp.c                |  2 +-
 net/llc/af_llc.c                   |  2 +-
 net/netlink/af_netlink.c           |  2 +-
 net/nfc/rawsock.c                  |  2 +-
 net/packet/af_packet.c             |  2 +-
 net/phonet/datagram.c              |  2 +-
 net/phonet/pep.c                   |  2 +-
 25 files changed, 45 insertions(+), 35 deletions(-)

-- 
2.7.4
