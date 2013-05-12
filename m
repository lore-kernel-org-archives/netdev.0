From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6,gre: do not leak info to user-space
Date: Sat, 11 May 2013 17:41:11 -0700 (PDT)
Message-ID: <20130511.174111.505312954327155391.davem@davemloft.net>
References: <1368172597-19183-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782Ab3ELAlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 20:41:12 -0400
In-Reply-To: <1368172597-19183-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 10 May 2013 15:56:37 +0800

> There is a hole in struct ip6_tnl_parm2, so we have to
> zero the struct on stack before copying it to user-space.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, and queued up for -stable.
