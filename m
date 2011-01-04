From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: typos in comments in include/linux/igmp.h
Date: Tue, 04 Jan 2011 11:30:01 -0800 (PST)
Message-ID: <20110104.113001.28819146.davem@davemloft.net>
References: <4D23709C.1040408@orange.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fx.lebail@orange.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52835
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751014Ab1ADT33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 14:29:29 -0500
In-Reply-To: <4D23709C.1040408@orange.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois-Xavier Le Bail <fx.lebail@orange.fr>
Date: Tue, 04 Jan 2011 20:10:20 +0100

> There are typos in comments in include/linux/igmp.h:
> 
> 83 #define IGMP_HOST_MEMBERSHIP_QUERY      0x11    /* From RFC1112 */
> 84 #define IGMP_HOST_MEMBERSHIP_REPORT     0x12    /* Ditto */
> [snip]
> 88 #define IGMPV2_HOST_MEMBERSHIP_REPORT   0x16    /* V2 version of 0x11 */
> 89 #define IGMP_HOST_LEAVE_MESSAGE         0x17
> 90 #define IGMPV3_HOST_MEMBERSHIP_REPORT   0x22    /* V3 version of 0x11 */
> 
> The line 88 and 90 are about REPORT messages.
> The IGMP_HOST_MEMBERSHIP_REPORT (IGMP V1) value is 0x12.
> So the comment on line 88 must be /* V2 version of 0x12 */,
> and the comment on line 90 must be /* V3 version of 0x12 */.
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@orange.fr>

Applied, thanks.
