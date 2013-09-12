From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: Make alb learning packet interval
 configurable
Date: Thu, 12 Sep 2013 16:49:48 -0400 (EDT)
Message-ID: <20130912.164948.1364121695106020281.davem@davemloft.net>
References: <1378822490-28667-1-git-send-email-nhorman@tuxdriver.com>
	<1378845543-14876-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@redhat.com, nhorman@redhat.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757225Ab3ILUtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 16:49:53 -0400
In-Reply-To: <1378845543-14876-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 10 Sep 2013 16:39:03 -0400

> From: Neil Horman <nhorman@redhat.com>
> 
> running bonding in ALB mode requires that learning packets be sent periodically,
> so that the switch knows where to send responding traffic.  However, depending
> on switch configuration, there may not be any need to send traffic at the
> default rate of 3 packets per second, which represents little more than wasted
> data.  Allow the ALB learning packet interval to be made configurable via sysfs
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

I hate to be a stickler, but I'd like you to make the default value
documented both in the code and in the documentation.

Use some macro for the code "#define BOND_ALB_DEFAULT_LP_INTERVAL 1" and
mention the default in the bonding.txt changes.

Thanks.
