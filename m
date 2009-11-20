From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] via-velocity: Implement NAPI support
Date: Fri, 20 Nov 2009 09:35:43 -0800 (PST)
Message-ID: <20091120.093543.12488098.davem@davemloft.net>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091120161223.10d01fd9@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58673
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753484AbZKTRfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:35:25 -0500
In-Reply-To: <20091120161223.10d01fd9@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Fri, 20 Nov 2009 16:12:23 +0100

> This patch adds NAPI support for VIA velocity. The new velocity_poll
> function also pairs tx/rx handling twice which improves perforamance on
> some workloads (e.g., netperf UDP_STREAM) significantly (that part is
> from the VIA driver).
> 
> Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>

With NAPI support present, your patch #3 should almost be not
necessary at all.

And if it is, make sure that you only use very low HW interrupt
mitigation settings.
