From: Andy Zhou <azhou@nicira.com>
Subject: [datapath minor fixes 0/3] datapath minor fixes
Date: Wed,  1 Oct 2014 00:55:45 -0700
Message-ID: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:44946 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750981AbaJAHyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 03:54:53 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so305142pdj.26
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 00:54:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few small issues found in preparing for GENEVE support upstreaming

*** BLURB HERE ***

Andy Zhou (3):
  datapath: avoid hard code OVS_VPORT_TYPE_GENEVE
  datapath: avoid double free routing entry in vxlan_port xmit
  datapath: serializing GENEVE options based on flow key's tun_flags

 datapath/flow_netlink.c                           | 2 +-
 datapath/linux/compat/include/linux/openvswitch.h | 2 +-
 datapath/vport-vxlan.c                            | 2 --
 3 files changed, 2 insertions(+), 4 deletions(-)

-- 
1.9.1
