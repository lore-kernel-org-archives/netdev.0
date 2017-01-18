From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6 net-next][V4] Rework inet_csk_get_port
Date: Wed, 18 Jan 2017 13:09:27 -0500 (EST)
Message-ID: <20170118.130927.1325940249673936603.davem@davemloft.net>
References: <20170117155106.22637-1-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kraigatgoog@gmail.com,
        eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37674 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751394AbdARSJ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 13:09:29 -0500
In-Reply-To: <20170117155106.22637-1-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Tue, 17 Jan 2017 07:51:00 -0800

> V3->V4:
> -Removed the random include of addrconf.h that is no longer needed.
> 
> V2->V3:
> -Dropped the fastsock from the tb and instead just carry the saddrs, family, and
>  ipv6 only flag.
> -Reworked the helper functions to deal with this change so I could still use
>  them when checking the fast path.
> -Killed tb->num_owners as per Eric's request.
> -Attached a reproducer to the bottom of this email.
> 
> V1->V2:
> -Added a new patch 'inet: collapse ipv4/v6 rcv_saddr_equal functions into one'
>  at Hannes' suggestion.
> -Dropped ->bind_conflict and just use the new helper.
> -Fixed a compile bug from the original ->bind_conflict patch.
> 
> The original description of the series follows
 ...

Series applied, thanks!
