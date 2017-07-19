From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] geneve: add rtnl changelink support
Date: Wed, 19 Jul 2017 16:51:16 -0700 (PDT)
Message-ID: <20170719.165116.1585585461311289445.davem@davemloft.net>
References: <1500420786-11993-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49266 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753702AbdGSXvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 19:51:17 -0400
In-Reply-To: <1500420786-11993-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Tue, 18 Jul 2017 16:33:06 -0700

> +static inline bool geneve_dst_addr_equal(struct ip_tunnel_info *a,
 ...
> +static inline void geneve_quiesce(struct geneve_dev *geneve,
 ...
> +static inline void geneve_unquiesce(struct geneve_dev *geneve,

Please no inline functions in foo.c files, let the compiler
decide.

Thanks.
