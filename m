From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [2.6.22] Remove unneeded pointer idev from
 addrconf_cleanup() in net/ipv6/addrconf.c
Date: Tue, 10 Jul 2007 23:05:06 -0700 (PDT)
Message-ID: <20070710.230506.111203158.davem@davemloft.net>
References: <aaab98560707082030w6521f4e5qf17a01d83d20faf8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pekkas@netcore.fi
To: micah.gruber@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754813AbXGKGeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 02:34:11 -0400
In-Reply-To: <aaab98560707082030w6521f4e5qf17a01d83d20faf8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Micah Gruber" <micah.gruber@gmail.com>
Date: Mon, 9 Jul 2007 11:30:46 +0800

> This trivial patch removes the unneeded pointer idev returned from
> __in6_dev_get(), which is never used. The check for NULL can be simply
> done by if (__in6_dev_get(dev) == NULL).
> 
> Signed-off-by: Micah Gruber < micah.gruber@gmail.com>

Applied, but your patch was severely white-space damaged by your
email client, please fix this up and test that the patches you
email out can be applied by those receiving the posting in the
future.

Thanks.
