From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net/dummy: add device group parameter
Date: Mon, 10 Jan 2011 13:37:48 -0800 (PST)
Message-ID: <20110110.133748.85424564.davem@davemloft.net>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
	<1294659524-22509-3-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, opurdila@ixiacom.com
To: ddvlad@rosedu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754265Ab1AJVhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:37:16 -0500
In-Reply-To: <1294659524-22509-3-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Dogaru <ddvlad@rosedu.org>
Date: Mon, 10 Jan 2011 13:38:43 +0200

> When inserting the dummy module, the user can specify the group of the
> dummy devices. This avoids manually moving the newly created pseudo
> devices to a different group.
> 
> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>

The amount of hacks people wish to add to the dummy driver is one step
away from amazing.

Just use the standard APIs to add dummy devices to the group you want,
instead of these ad-hoc device specific module parameters.

Thanks.
