From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] remove obsolete shaper code
Date: Wed, 22 Aug 2007 17:01:33 -0700 (PDT)
Message-ID: <20070822.170133.05603862.davem@davemloft.net>
References: <20070822165854.7a65f099@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60940
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932493AbXHWABg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 20:01:36 -0400
In-Reply-To: <20070822165854.7a65f099@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 22 Aug 2007 16:58:54 -0700

> This driver is obsolete, and fixing it for adding upcoming changes
> to make hard_header_ops
> is problematic because it changes the underlying device handles.
> 
> The driver has been superseded by iproute2/traffic control for
> a long time. Let's kill it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Please do this with a proper feature-removal-schedule.txt entry and
timeframe.
