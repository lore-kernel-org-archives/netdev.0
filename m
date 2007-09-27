From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net ipv4: Remove unnecessary test for the loopback
 device from inetdev_destroy
Date: Wed, 26 Sep 2007 22:09:43 -0700 (PDT)
Message-ID: <20070926.220943.31293195.davem@davemloft.net>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751320AbXI0FJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 01:09:43 -0400
In-Reply-To: <m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Sep 2007 17:55:29 -0600

> 
> Currently we never call unregister_netdev for the loopback device so
> it is impossible for us to reach inetdev_destroy with the loopback
> device.  So the test in inetdev_destroy is unnecessary.
> 
> Further when testing with my network namespace patches removing
> unregistering the loopback device and calling inetdev_destroy works
> fine so there appears to be no reason for avoiding unregistering the
> loopback device.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Fair enough, applied to net-2.6.24
