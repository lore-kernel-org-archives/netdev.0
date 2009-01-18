From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/34]bnx2x: Carrier off first call
Date: Sat, 17 Jan 2009 23:18:43 -0800 (PST)
Message-ID: <20090117.231843.104773494.davem@davemloft.net>
References: <1231951424.11301.142.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757674AbZARHSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:18:42 -0500
In-Reply-To: <1231951424.11301.142.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:44 +0200

> Call carrier off should not be called after register_netdev since after
> register netdef open can be called at any time followed by an interrupt that
> will set it to carrier_on and the probe will resume control and set it to off
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
