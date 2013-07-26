From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] neigh: prevent overflowing params in
 /proc/sys/net/ipv4/neigh/
Date: Fri, 26 Jul 2013 14:22:31 -0700 (PDT)
Message-ID: <20130726.142231.339341472515071199.davem@davemloft.net>
References: <cover.1374654531.git.ffusco@redhat.com>
	<cover.1374654531.git.ffusco@redhat.com>
	<ceef40ec2f64a50afcfc43375a9306ab0661fdf7.1374654531.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ffusco@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760631Ab3GZVWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:22:35 -0400
In-Reply-To: <ceef40ec2f64a50afcfc43375a9306ab0661fdf7.1374654531.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Fusco <ffusco@redhat.com>
Date: Wed, 24 Jul 2013 10:39:06 +0200

> Without this patch, the fields app_solicit, gc_thresh1, gc_thresh2,
> gc_thresh3, proxy_qlen, ucast_solicit, mcast_solicit could have
> assumed negative values when setting large numbers.
> 
> Signed-off-by: Francesco Fusco <ffusco@redhat.com>

Applied.
