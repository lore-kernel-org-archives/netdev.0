From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] netpoll: prevent netpoll setup on slave devices
Date: Thu, 09 Jun 2011 00:28:52 -0700 (PDT)
Message-ID: <20110609.002852.1260136420485959418.davem@davemloft.net>
References: <1307587360-3092-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871Ab1FIH35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 03:29:57 -0400
In-Reply-To: <1307587360-3092-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amerigo Wang <amwang@redhat.com>
Date: Thu,  9 Jun 2011 10:42:40 +0800

> In commit 8d8fc29d02a33e4bd5f4fa47823c1fd386346093
> (netpoll: disable netpoll when enslave a device), we automatically
> disable netpoll when the underlying device is being enslaved,
> we also need to prevent people from setuping netpoll on
> devices that are already enslaved.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Applied, thanks.
