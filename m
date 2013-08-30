From: David Miller <davem@davemloft.net>
Subject: Re: [patch] mISDN: return -EINVAL on error in dsp_control_req()
Date: Fri, 30 Aug 2013 17:53:49 -0400 (EDT)
Message-ID: <20130830.175349.2106772870180002395.davem@davemloft.net>
References: <20130829084700.GF14334@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, khlebnikov@openvz.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab3H3Vxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:53:51 -0400
In-Reply-To: <20130829084700.GF14334@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 29 Aug 2013 11:47:00 +0300

> If skb->len is too short then we should return an error.  Otherwise we
> read beyond the end of skb->data for several bytes.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
