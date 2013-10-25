From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] fix rtnl notification in atomic context
Date: Fri, 25 Oct 2013 19:05:20 -0400 (EDT)
Message-ID: <20131025.190520.232793611249518968.davem@davemloft.net>
References: <1382569362-4820-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, amwang@redhat.com, vfalico@redhat.com,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab3JYXFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:05:22 -0400
In-Reply-To: <1382569362-4820-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 23 Oct 2013 16:02:42 -0700

> commit 991fb3f74c "dev: always advertise rx_flags changes via netlink"
> introduced rtnl notification from __dev_set_promiscuity(),
> which can be called in atomic context.
> 
> Steps to reproduce:
> ip tuntap add dev tap1 mode tap
> ifconfig tap1 up
> tcpdump -nei tap1 &
> ip tuntap del dev tap1 mode tap
 ...
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
