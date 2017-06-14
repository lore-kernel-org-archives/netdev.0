From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:30:33 +0800
Message-ID: <1497450634-3581-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:35154 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752015AbdFNObQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:31:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>


yuan linyu (11):
  ipv6: skb_put_zero() used to optimize code
  ipv4: skb_put_zero() used to optimize code
  ncsi: skb_put_zero() used to optimize code
  dsa: skb_put_zero() used to optimize code
  key: skb_put_zero() used to optimize code
  openvswitch: skb_put_zero() used to optimize code
  batman-adv: skb_put_zero() used to optimize code
  bridge: skb_put_zero() used to optimize code
  sctp: skb_put_zero() used to optimize code
  atm: skb_put_zero() used to optimize code
  qrtr: skb_put_zero() used to optimize code

 net/atm/signaling.c                      |  3 +--
 net/batman-adv/bat_v_elp.c               |  3 +--
 net/bridge/netfilter/nft_reject_bridge.c |  6 ++----
 net/dsa/tag_trailer.c                    |  3 +--
 net/ipv4/ipconfig.c                      |  3 +--
 net/ipv4/netfilter/nf_reject_ipv4.c      |  3 +--
 net/ipv6/mcast.c                         |  3 +--
 net/ipv6/ndisc.c                         | 13 ++----------
 net/key/af_key.c                         | 12 ++++-------
 net/ncsi/ncsi-cmd.c                      | 36 +++++++++++---------------------
 net/openvswitch/datapath.c               |  2 +-
 net/qrtr/qrtr.c                          |  9 +++-----
 net/sctp/output.c                        |  2 +-
 13 files changed, 31 insertions(+), 67 deletions(-)

-- 
2.7.4
