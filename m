From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bonding: Make alb learning packet interval
 configurable
Date: Mon, 16 Sep 2013 00:53:56 -0400 (EDT)
Message-ID: <20130916.005356.334677152626469973.davem@davemloft.net>
References: <1378822490-28667-1-git-send-email-nhorman@tuxdriver.com>
	<1379084733-9219-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@redhat.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab3IPEx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 00:53:58 -0400
In-Reply-To: <1379084733-9219-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 13 Sep 2013 11:05:33 -0400

> running bonding in ALB mode requires that learning packets be sent periodically,
> so that the switch knows where to send responding traffic.  However, depending
> on switch configuration, there may not be any need to send traffic at the
> default rate of 3 packets per second, which represents little more than wasted
> data.  Allow the ALB learning packet interval to be made configurable via sysfs
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Acked-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks Neil.
