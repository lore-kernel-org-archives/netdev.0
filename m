From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] /proc/net/anycast6 unbalanced inet6_dev refcnt
Date: Mon, 26 Feb 2007 16:29:23 -0800 (PST)
Message-ID: <20070226.162923.85417564.davem@davemloft.net>
References: <OF11F5BC96.16E9F85A-ON8825728F.00018101-8825728F.00020608@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751492AbXB0A3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 19:29:25 -0500
In-Reply-To: <OF11F5BC96.16E9F85A-ON8825728F.00018101-8825728F.00020608@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Mon, 26 Feb 2007 17:22:10 -0700

> Reading /proc/net/anycast6 when there is no anycast address
> on an interface results in an ever-increasing inet6_dev reference
> count, as well as a reference to the netdevice you can't get rid of.

Applied, thanks a lot David.

I'll send this off to -stable too.
