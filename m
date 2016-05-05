From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 00/12] net-next: mediatek: bug fixes and tx stall fixes
Date: Thu, 5 May 2016 14:25:34 +0200
Message-ID: <20160505122534.GF7972@lunn.ch>
References: <1462440385-51939-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, nbd@nbd.name,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57549 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000AbcEEMZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 08:25:43 -0400
Content-Disposition: inline
In-Reply-To: <1462440385-51939-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 11:26:13AM +0200, John Crispin wrote:
> This series is a collection of fixes for bugs that we stumble across while
> doing more performance testing and code level review.

Hi John

I just noticed the code uses kfree(mii_bus), rather than
mdiobus_free(mii_bus).

	Andrew
