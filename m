From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPV4] Remove bugus goto-s from ip_route_input_slow
Date: Sat, 10 Nov 2007 21:26:57 -0800 (PST)
Message-ID: <20071110.212657.125657722.davem@davemloft.net>
References: <4735BFE6.8010108@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751622AbXKKF06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:26:58 -0500
In-Reply-To: <4735BFE6.8010108@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sat, 10 Nov 2007 17:27:50 +0300

> Both places look like
> 
>         if (err == XXX) 
>                goto yyy;
>    done:
> 
> while both yyy targets look like
> 
>         err = XXX;
>         goto done;
> 
> so this is ok to remove the above if-s.
> 
> yyy labels are used in other places and are not removed.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
