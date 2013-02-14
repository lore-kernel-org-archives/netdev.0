From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] netpoll: add some missing __rcu marks in
 several places
Date: Thu, 14 Feb 2013 13:20:54 -0500 (EST)
Message-ID: <20130214.132054.2237485951582283881.davem@davemloft.net>
References: <20130213223935.122d035b@nehalam.linuxnetplumber.net>
	<1360831039-11418-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, vyasevic@redhat.com,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758371Ab3BNSU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:20:56 -0500
In-Reply-To: <1360831039-11418-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 14 Feb 2013 16:37:19 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> This fixes sparse warnings like the one below:
> 
> drivers/net/team/team.c:953:25: warning: incorrect type in return expression (different address spaces)
> drivers/net/team/team.c:953:25:    expected struct netpoll_info *
> drivers/net/team/team.c:953:25:    got struct netpoll_info [noderef] <asn:4>*npinfo
> 
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

This is a very confusing patch submission.

You're posting a "v2" of a patch but with a completely different Subject
line so that it's hard, without looking into the details of the patch,
to determine what this patch is a "v2" of.

You've also not addressed Stephen's feedback about the lack of an
rcu_dereference() in these routines you've added __rcu annotations
to.

I'm tossing all versions of this patch, therefore.
