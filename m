From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net ipv4: When possible test for IFF_LOOPBACK and
 not dev == loopback_dev
Date: Wed, 26 Sep 2007 22:10:18 -0700 (PDT)
Message-ID: <20070926.221018.18301963.davem@davemloft.net>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
	<m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750999AbXI0FKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 01:10:18 -0400
In-Reply-To: <m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Sep 2007 17:58:21 -0600

> 
> Now that multiple loopback devices are becoming possible it makes
> the code a little cleaner and more maintainable to test if a deivice
> is th a loopback device by testing dev->flags & IFF_LOOPBACK instead
> of dev == loopback_dev.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
