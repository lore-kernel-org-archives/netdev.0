From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFT] bcm43xx-softmac: match specifications change in rssi
	processing
Date: Mon, 20 Nov 2006 09:51:35 +0100
Message-ID: <1164012695.2744.8.camel@ux156>
References: <4560EC72.mailJBO11D63L@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51869 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S934014AbWKTIuZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 03:50:25 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <4560EC72.mailJBO11D63L@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-11-19 at 17:44 -0600, Larry Finger wrote:
> 
> +       lna = (rxhdr->phy_rx_status2 & 0xc0000) >> 14; 

I think you probably ought to have defines for the mask and shift here.

johannes
