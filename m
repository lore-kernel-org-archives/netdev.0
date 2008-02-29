From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] New Update on CUBIC
Date: Fri, 29 Feb 2008 10:46:33 -0800 (PST)
Message-ID: <20080229.104633.167255557.davem@davemloft.net>
References: <008401c87ad6$aea52e30$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: rhee@eos.ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758407AbYB2Sqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 13:46:33 -0500
In-Reply-To: <008401c87ad6$aea52e30$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Injong Rhee" <rhee@eos.ncsu.edu>
Date: Fri, 29 Feb 2008 08:26:24 -0500

> @@ -211,19 +205,6 @@ static inline void bictcp_update(struct bictcp *ca, u32 
> cwnd)
>   ca->cnt = 100 * cwnd;              /* very small increment*/
>   }
> 
> - if (ca->delay_min > 0) {
> - /* max increment = Smax * rtt / 0.1  */
> - min_cnt = (cwnd * HZ * 8)/(10 * max_increment * ca->delay_min);
> -

Please configure your email client to not corrupt the tabbing and to
also not break up long lines, as this makes the patch unusable.

Thank you.
