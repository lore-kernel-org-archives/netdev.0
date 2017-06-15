From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: sched: act_tunnel_key: UDP checksums
Date: Thu, 15 Jun 2017 14:21:26 -0400 (EDT)
Message-ID: <20170615.142126.2291497856328892133.davem@davemloft.net>
References: <cover.1497467840.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752763AbdFOSV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 14:21:29 -0400
In-Reply-To: <cover.1497467840.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 14 Jun 2017 21:19:29 +0200

> Currently, the tunnel_key tc action does not set TUNNEL_CSUM, thus
> transmitting packets with zero UDP checksum. This is inconsistent with how
> we treat non-lwt UDP tunnels where the default is to fill in the UDP
> checksum. Non-zero UDP checksum is the better default anyway for various
> reasons previously discussed.
> 
> Make this configurable for the tunnel_key tc action with the default being
> non-zero checksum. Saves a lot of surprises especially with IPv6.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Seems reasonable, series applied, thanks.
