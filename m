From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tcp: fixes some congestion control corner
 cases
Date: Thu, 09 Jul 2015 14:23:15 -0700 (PDT)
Message-ID: <20150709.142315.1972696129360030817.davem@davemloft.net>
References: <1436472991-16056-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vanj@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbbGIVXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 17:23:16 -0400
In-Reply-To: <1436472991-16056-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu,  9 Jul 2015 13:16:28 -0700

> This patch series fixes corner cases of TCP congestion control.
> First issue is to avoid continuing slow start when cwnd reaches ssthresh.
> Second issue is incorrectly processing order of congestion state and
> cwnd update when entering fast recovery or undoing cwnd.
> 
> Yuchung Cheng (3):
>   tcp: add tcp_in_slow_start helper
>   tcp: do not slow start when cwnd equals ssthresh
>   tcp: update congestion state first before raising cwnd

This helper function is long overdue, nice work.

Series applied, thanks!
