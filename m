From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH 0/2] vlan TSO support for virtio-net
Date: Thu, 11 Apr 2013 17:32:20 +0800
Message-ID: <1365672742-42258-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series simply enable the vlan TSO support for virtio-net by just initialize
vlan_features for virtio-net and tun which allows vlan TSO packets to be
processed in both TX and RX path for virtio-net.

Netperf shows great improvements on stream tests:

Before:
Guest sending:   4162.35 10^6bits/sec
Guest receiving: 2786.67 10^6bit/sec

After:
Guest sending:   9365.42 10^6bits/sec
Guest receiving: 8085.49 10^6bit/sec

Jason Wang (2):
  virtio-net: initialize vlan_features
  tuntap: initialize vlan_features

 drivers/net/tun.c        |    1 +
 drivers/net/virtio_net.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)
