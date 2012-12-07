From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] tun: correctly report an error in
 tun_flow_init()
Date: Fri, 07 Dec 2012 13:21:09 -0500 (EST)
Message-ID: <20121207.132109.658096484045379137.davem@davemloft.net>
References: <20121206154838.6073.17102.stgit@localhost>
	<3078848.lXJIGSkO7f@jason-thinkpad-t430s>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pmoore@redhat.com, netdev@vger.kernel.org
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423658Ab2LGSVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 13:21:11 -0500
In-Reply-To: <3078848.lXJIGSkO7f@jason-thinkpad-t430s>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 07 Dec 2012 13:51:47 +0800

> On Thursday, December 06, 2012 10:48:38 AM Paul Moore wrote:
>> On error, the error code from tun_flow_init() is lost inside
>> tun_set_iff(), this patch fixes this by assigning the tun_flow_init()
>> error code to the "err" variable which is returned by
>> the tun_flow_init() function on error.
>> 
>> Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> Acked-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
