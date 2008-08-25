From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] bnx2x: Rx work check
Date: Mon, 25 Aug 2008 15:21:00 -0700 (PDT)
Message-ID: <20080825.152100.38360120.davem@davemloft.net>
References: <1219674265.19456.27.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44354
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbYHYWVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:21:03 -0400
In-Reply-To: <1219674265.19456.27.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 25 Aug 2008 17:24:25 +0300

> The has Rx work check was wrong: when the FW was at the end of the page,
> the driver was already at the beginning of the next page. Since the
> check only validated that both driver and FW are pointing to the same
> place, it concluded that there is still work to be done. This caused
> some serious issues including long latency results on ping-pong test and
> lockups while unloading the driver in that condition.
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
