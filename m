From: David Miller <davem@davemloft.net>
Subject: Re: [i4l] do not print a warning when shutting down an i4l ppp
 interface
Date: Wed, 14 Jan 2009 14:41:09 -0800 (PST)
Message-ID: <20090114.144109.146110279.davem@davemloft.net>
References: <1231764197.7132.12.camel@test.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759412AbZANWlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 17:41:08 -0500
In-Reply-To: <1231764197.7132.12.camel@test.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 12 Jan 2009 13:43:17 +0100

> When an i4l ppp interface is shut down (e.g. with /sbin/ifdown ippp0) a
> scary warning is logged:
>     
>     isdn_free_channel: called with invalid drv(-1) or channel(-1)
>     
> This warning is caused by isdn_net_unbind_channel(), which always calls
> isdn_free_channel() even if isdn_net_local->isdn_device and
> isdn_net_local->isdn_channel are (still) in a perfectly acceptable
> default state, so let's not do that.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied.
