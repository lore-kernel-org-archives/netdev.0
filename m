From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/5] ipv6: Compute multipath hash for sent
 ICMP errors from offending packet
Date: Thu, 27 Oct 2016 11:24:13 -0400 (EDT)
Message-ID: <20161027.112413.1616222035100737672.davem@davemloft.net>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
        <1477301332-23954-5-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, edumazet@google.com
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53736 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933351AbcJ0PYP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 11:24:15 -0400
In-Reply-To: <1477301332-23954-5-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Mon, 24 Oct 2016 11:28:51 +0200

> diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
> index 57086e9..6282e03 100644
> --- a/include/linux/icmpv6.h
> +++ b/include/linux/icmpv6.h
> @@ -45,4 +45,6 @@ extern void				icmpv6_flow_init(struct sock *sk,
>  							 const struct in6_addr *saddr,
>  							 const struct in6_addr *daddr,
>  							 int oif);
> +struct ipv6hdr;
> +extern u32				icmpv6_multipath_hash(const struct ipv6hdr *iph);
>  #endif

We do not use "extern" in external function declarations in header file any more.
