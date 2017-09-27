From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] mlxsw: Introduce support for "pass" gact
 action offloading
Date: Tue, 26 Sep 2017 20:35:37 -0700 (PDT)
Message-ID: <20170926.203537.925494537363696967.davem@davemloft.net>
References: <20170925085822.1358-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030881AbdI0Dfi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 23:35:38 -0400
In-Reply-To: <20170925085822.1358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 25 Sep 2017 10:58:19 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Very simple patchset adds ability for user to insert filters with "pass"
> gact action and offload it. That allows scenarios like this:
> 
> $ tc filter add dev enp3s0np19 ingress protocol ip pref 10 flower skip_sw dst_ip 192.168.101.0/24 action drop
> $ tc filter add dev enp3s0np19 ingress protocol ip pref 9 flower skip_sw dst_ip 192.168.101.1 action pass

Series applied, thanks.
