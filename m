From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
 prior to interface-up
Date: Sun, 13 Apr 2008 22:44:33 -0700 (PDT)
Message-ID: <20080413.224433.243167397.davem@davemloft.net>
References: <1207839617.4311.6.camel@compaq.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	jgarzik@redhat.com
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41715
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752343AbYDNFoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:44:32 -0400
In-Reply-To: <1207839617.4311.6.camel@compaq.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 10 Apr 2008 17:00:17 +0200

> From: Paul Bolle <pebolle@tiscali.nl>
>    
> Commit bada339 (Validate device addr prior to interface-up) caused a regression
> in the ISDN network code, see: http://bugzilla.kernel.org/show_bug.cgi?id=9923
> The trivial fix is to remove the pointer to eth_validate_addr() in the
> net_device struct in isdn_net_init().
>     
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied, thanks a lot Paul.
