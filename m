From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] move size information to pr_debug()
Date: Sat, 12 Jan 2008 20:53:13 -0800 (PST)
Message-ID: <20080112.205313.83109889.davem@davemloft.net>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.207183428@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48438
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753628AbYAMExO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 23:53:14 -0500
In-Reply-To: <20080112064646.207183428@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 11 Jan 2008 22:45:16 -0800

> The size of structures is a debug thing, not something that needs to
> be part of a /proc api.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

I don't necessarily agree with this one, the size of the
structures is an important inherent attribute contributing
directly to memory usage and performance of the algorithms.
So knowing those values are necessary to diagnose problems.
