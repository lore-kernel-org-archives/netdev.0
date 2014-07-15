From: Jongsung Kim <neidhard.kim@lge.com>
Subject: Re: [PATCH 1/2] net: cadence: macb: add support for the WOL
Date: Tue, 15 Jul 2014 16:02:34 +0900
Message-ID: <53C4D20A.2050909@lge.com>
References: <1405328538-29153-1-git-send-email-neidhard.kim@lge.com> <53C3ADB9.4010309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Varka Bhadram <varkabhadram@gmail.com>, nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from LGEMRELSE7Q.lge.com ([156.147.1.151]:48437 "EHLO
	lgemrelse7q.lge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757767AbaGOHCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 03:02:36 -0400
In-Reply-To: <53C3ADB9.4010309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2014 07:15 PM, Varka Bhadram wrote:
> 
> I think we can do in this way:
> 
> if (phydev)
>     return phy_ethtool_set_wol(phydev, wol);
> else
>     return -ENODEV;
> 
> 
> we can save err. What do you say ...?
> 

Thank you for your comment. I just wanted the function to return
at one position. However, I'll think about your point..
