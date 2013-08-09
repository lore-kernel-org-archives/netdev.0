From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vxlan: fix a regression of igmp join
Date: Fri, 09 Aug 2013 11:42:34 -0700 (PDT)
Message-ID: <20130809.114234.858855631098720366.davem@davemloft.net>
References: <1375864545-5721-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967943Ab3HISmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:42:35 -0400
In-Reply-To: <1375864545-5721-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed,  7 Aug 2013 16:35:45 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> This is a regression introduced by:
> 
> 	commit 3fc2de2faba387218bdf9dbc6b13f513ac3b060a
> 	Author: stephen hemminger <stephen@networkplumber.org>
> 	Date:   Thu Jul 18 08:40:15 2013 -0700
> 
> 	    vxlan: fix igmp races
> 
> Before this commit, the old code was:
> 
>        if (vxlan_group_used(vn, vxlan->default_dst.remote_ip))
>                ip_mc_join_group(sk, &mreq);
>        else
>                ip_mc_leave_group(sk, &mreq);
> 
> therefore we shoud check vxlan_group_used(), not its opposite,
> for igmp_join.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
