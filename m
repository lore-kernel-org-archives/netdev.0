From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 0/6] iproute2: add changes for switchdev
Date: Thu,  4 Dec 2014 09:57:12 +0100
Message-ID: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:50771 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbaLDI5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 03:57:21 -0500
Received: by mail-wg0-f49.google.com with SMTP id n12so13812818wgh.36
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 00:57:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (1):
  iproute2: ipa: show switch id

Scott Feldman (5):
  bridge/fdb: fix statistics output spacing
  bridge/fdb: add flag/indication for FDB entry synced from offload
    device
  bridge/link: add new offload hwmode swdev
  link: add missing IFLA_BRPORT_PROXYARP
  bridge/link: add learning_sync policy flag

 bridge/fdb.c              |  4 +++-
 bridge/link.c             | 17 +++++++++++++++--
 include/linux/if_bridge.h |  1 +
 include/linux/if_link.h   |  3 +++
 include/linux/neighbour.h |  1 +
 ip/ipaddress.c            |  8 ++++++++
 man/man8/bridge.8         | 19 ++++++++++++++-----
 7 files changed, 45 insertions(+), 8 deletions(-)

-- 
1.9.3
