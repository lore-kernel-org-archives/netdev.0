From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: always pass struct netdev_notifier_info
 to netdevice notifiers
Date: Tue, 28 May 2013 21:59:08 -0700 (PDT)
Message-ID: <20130528.215908.886300995908634641.davem@davemloft.net>
References: <1369798250-25798-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863Ab3E2E7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 00:59:11 -0400
In-Reply-To: <1369798250-25798-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 29 May 2013 11:30:50 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> commit 351638e7deeed2ec8ce451b53d3 (net: pass info struct via netdevice notifier)
> breaks booting of my KVM guest, this is due to we still forget to pass
> struct netdev_notifier_info in several places. This patch completes it.
> 
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks for the quick fix.
