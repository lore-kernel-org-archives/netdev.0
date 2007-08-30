From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] bridge: packets leaking out of disabled/blocked ports
Date: Thu, 30 Aug 2007 16:03:13 -0400
Message-ID: <20070830200313.GF5140@tuxdriver.com>
References: <20070829150515.54dd7ecf@freepuppy.rosehill.hemminger.net> <426497.88154.qm@web51910.mail.re2.yahoo.com> <20070830122258.1c606516@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wang dengyi <dy_wang@yahoo.com>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4658 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758132AbXH3Uot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 16:44:49 -0400
Content-Disposition: inline
In-Reply-To: <20070830122258.1c606516@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 12:22:58PM -0700, Stephen Hemminger wrote:
> This patch fixes some packet leakage in bridge.  The bridging code
> was allowing forward table entries to be generated even if a device
> was being blocked. The fix is to not add forwarding database entries
> unless the port is active.

Seems reasonable -- ACK

John
-- 
John W. Linville
linville@tuxdriver.com
