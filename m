From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 3/3] vxlan: defer vxlan init as late as
 possible
Date: Tue, 28 May 2013 23:54:34 -0700 (PDT)
Message-ID: <20130528.235434.2115409533967659972.davem@davemloft.net>
References: <1369730153-11214-1-git-send-email-amwang@redhat.com>
	<1369730153-11214-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934396Ab3E2Gyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:54:35 -0400
In-Reply-To: <1369730153-11214-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 28 May 2013 16:35:53 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> When vxlan is compiled as builtin, its init code
> runs before IPv6 init, this could cause problems
> if we create IPv6 socket in the latter patch.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
