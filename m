From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/6] introduce trap control action to tc
 and offload it
Date: Tue, 06 Jun 2017 12:45:46 -0400 (EDT)
Message-ID: <20170606.124546.1005029301517245767.davem@davemloft.net>
References: <20170606121207.2921-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com, andrew@lunn.ch
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdFFQpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 12:45:49 -0400
In-Reply-To: <20170606121207.2921-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  6 Jun 2017 14:12:01 +0200

> This patchset introduces a control action dedicated to indicate
> to trap the matched packet to CPU. This is specific action for
> HW offloads. Also, the patchset offloads the action to mlxsw driver.
> 
> Example usage:
> $ tc filter add dev enp3s0np19 parent ffff: protocol ip prio 20 flower skip_sw dst_ip 192.168.10.1 action trap

Series applied, thanks Jiri.
