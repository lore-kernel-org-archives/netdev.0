From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] random32: use msecs_to_jiffies for reseed timer
Date: Thu, 14 Nov 2013 16:07:00 -0500 (EST)
Message-ID: <20131114.160700.956185155383758489.davem@davemloft.net>
References: <1384296342-3348-1-git-send-email-dborkman@redhat.com>
	<1384296342-3348-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108Ab3KNVHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:07:03 -0500
In-Reply-To: <1384296342-3348-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 12 Nov 2013 23:45:42 +0100

> Use msecs_to_jiffies, for these calculations as different HZ
> considerations are taken into account for conversion of the timer
> shot, and also it makes the code more readable.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
