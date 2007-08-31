From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: packets leaking out of disabled/blocked ports
Date: Thu, 30 Aug 2007 22:15:44 -0700 (PDT)
Message-ID: <20070830.221544.48531675.davem@davemloft.net>
References: <426497.88154.qm@web51910.mail.re2.yahoo.com>
	<20070830122258.1c606516@freepuppy.rosehill.hemminger.net>
	<20070830200313.GF5140@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, dy_wang@yahoo.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756289AbXHaFPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:15:46 -0400
In-Reply-To: <20070830200313.GF5140@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 30 Aug 2007 16:03:13 -0400

> On Thu, Aug 30, 2007 at 12:22:58PM -0700, Stephen Hemminger wrote:
> > This patch fixes some packet leakage in bridge.  The bridging code
> > was allowing forward table entries to be generated even if a device
> > was being blocked. The fix is to not add forwarding database entries
> > unless the port is active.
> 
> Seems reasonable -- ACK

Applied, thanks.
