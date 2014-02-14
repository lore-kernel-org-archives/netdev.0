From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [Patch net-next] openvswitch: rename ->sync to ->syncp
Date: Fri, 14 Feb 2014 21:46:34 -0200
Message-ID: <20140214234634.GC3173@localhost.localdomain>
References: <1392419446-4559-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828AbaBNXqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:46:39 -0500
Content-Disposition: inline
In-Reply-To: <1392419446-4559-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 03:10:46PM -0800, Cong Wang wrote:
> Openvswitch defines u64_stats_sync as ->sync rather than ->syncp,
> so fails to compile with netdev_alloc_pcpu_stats(). So just rename it to ->syncp.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 1c213bd24ad04f4430031 (net: introduce netdev_alloc_pcpu_stats() for drivers)
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ---

Reviewed-by: Flavio Leitner <fbl@redhat.com>
