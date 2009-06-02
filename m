From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 01 Jun 2009 19:04:30 -0700 (PDT)
Message-ID: <20090601.190430.80366622.davem@davemloft.net>
References: <4A23F027.3060907@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58957
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754706AbZFBCE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 22:04:29 -0400
In-Reply-To: <4A23F027.3060907@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Mon, 01 Jun 2009 17:13:43 +0200

> RFC indicates that a router must drop the packet if this field is 0.

It only must do this when executing the forwarding function.  It's an
egress check, not an ingress one.

I'm not applying this patch, it can even break some applications
out there that use a TTL of zero intentionally to keep traffic
only on a local subnet.
