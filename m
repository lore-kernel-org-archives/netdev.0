From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4][TG3]: Assign tp->link_config.orig_* values.
Date: Sun, 17 Dec 2006 17:07:00 -0800 (PST)
Message-ID: <20061217.170700.126071058.davem@davemloft.net>
References: <1166251702.30429.9.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57411
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753340AbWLRBHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 20:07:00 -0500
To: mchan@broadcom.com
In-Reply-To: <1166251702.30429.9.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 15 Dec 2006 22:48:22 -0800

> [TG3]: Assign tp->link_config.orig_* values.
> 
> tp->link_config.orig_* values must be assigned during
> tg3_set_settings() because these values will be used to setup the
> link speed during tg3_open().  Without these assignments, the link
> speed settings will be all messed by if tg3_set_settings() is called
> when the device is down.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Good catch, patch applied, thanks Michael.
