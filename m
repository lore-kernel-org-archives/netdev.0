From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] qlge: Allow running MSIx with fewer
 vectors.
Date: Fri, 28 Aug 2009 23:23:08 -0700 (PDT)
Message-ID: <20090828.232308.200741893.davem@davemloft.net>
References: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751770AbZH2GWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:22:54 -0400
In-Reply-To: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 27 Aug 2009 14:02:08 -0700

> The purpose of this patch series is to allow MSIx usage on
> platforms where vector availability is limited.  The change is to
> move broadcast/multicast/firmware event processing from a dedicated
> 'default' ring into the first RSS ring, and move TX completion
> processing into NAPI context.

These look good, thanks for reworking these do many times :-)

All applied to net-next-2.6
