From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v0] bonding: Display LACP info only to
 CAP_SYS_ADMIN capable user
Date: Thu, 11 Jun 2015 15:22:57 -0700 (PDT)
Message-ID: <20150611.152257.1284649637451689093.davem@davemloft.net>
References: <1433981996-6010-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	maze@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbbFKWW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 18:22:58 -0400
In-Reply-To: <1433981996-6010-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 10 Jun 2015 17:19:56 -0700

> Actor and Partner details can be accessed via proc-fs and sys-fs
> entries. These interfaces are world readable at this moment. The
> earlier patch-series made the LACP communication secure to avoid
> nuisance attack from within the same L2 domain but it did not
> prevent "someone unprivileged" looking at that information on host
> and perform the same act.
> 
> This patch essentially avoids spitting those entries if the user
> in question does not have enough privileges.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

I agree with Stephen Hemminger in that you should probably be using
CAP_NET_ADMIN here.
