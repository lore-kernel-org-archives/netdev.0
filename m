From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net-next 07/27] net: add for_each iterators through
 neighbour lower link's private
Date: Wed, 11 Sep 2013 01:46:24 +0000 (UTC)
Message-ID: <l0oi1g$jo6$1@ger.gmane.org>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
 <1378846691-9717-8-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:34890 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab3IKBqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 21:46:45 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VJZVz-0001zb-MZ
	for netdev@vger.kernel.org; Wed, 11 Sep 2013 03:46:43 +0200
Received: from 117.57.109.128 ([117.57.109.128])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 03:46:43 +0200
Received: from xiyou.wangcong by 117.57.109.128 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 03:46:43 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Sep 2013 at 20:57 GMT, Veaceslav Falico <vfalico@redhat.com> wrote:
> +void *netdev_lower_get_next_private_rcu(struct net_device *dev,
> +					struct list_head **iter)
> +{
> +	struct netdev_adjacent *lower;
> +
> +	WARN_ON_ONCE(!rcu_read_lock_held());
> +

Since this function has _rcu suffix, this warning is not useful at all.
