From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS]: Remove empty ->init callback.
Date: Mon, 21 Apr 2008 14:33:47 -0700 (PDT)
Message-ID: <20080421.143347.108170137.davem@davemloft.net>
References: <480CACE0.4070109@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58424
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756618AbYDUVdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 17:33:45 -0400
In-Reply-To: <480CACE0.4070109@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 21 Apr 2008 19:04:00 +0400

> The netns start-stop engine can happily live with any of
> init or exit callbacks set to NULL.
> 
> Isn't it too late to merge this one?

No, it fixes the bug that extraneous kernel text space is
used by code that does nothing :-)

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
