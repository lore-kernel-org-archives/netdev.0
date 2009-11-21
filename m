From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] net: persistent device name bitmaps for faster name
 allocation
Date: Fri, 20 Nov 2009 16:57:02 -0800
Message-ID: <20091120165702.2b337e46@nehalam>
References: <200911210237.25855.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33691 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652AbZKUA5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 19:57:17 -0500
In-Reply-To: <200911210237.25855.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Nov 2009 02:37:25 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> This patch solves the current scalability issues of dev_name_alloc() by
> making the device name bitmap persistent. It is based on an idea
> suggested by Stephen Hemminger.

Still not sure that this much code is worth it. Even with 10000 ISP PPPoE links,
I can't see that bringing up a new PPP device would be the real bottleneck
except in the case of some benchmark that starts them all at once. Even TPC-C
benchmarks have a "warm up period".

-- 
