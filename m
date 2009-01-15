From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/34]bnx2x: Using singlethread work queue
Date: Wed, 14 Jan 2009 21:23:02 -0800 (PST)
Message-ID: <20090114.212302.80063588.davem@davemloft.net>
References: <1231951360.11301.122.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753430AbZAOFXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:23:01 -0500
In-Reply-To: <1231951360.11301.122.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:42:40 +0200

> Since slow-path events, including link update, are handled in
> work-queue, a race condition was introduced in the self-test that
> sometimes caused the link status to fail: the self-test was running
> under RTNL lock, and if the link-watch was scheduled it stoped the
> shared work-queue (waiting for the RTNL lock) and so the link update
> event was not handled until the self-test ended (releasing the RTNL
> lock) with failure (since the link status was not updated)
>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
