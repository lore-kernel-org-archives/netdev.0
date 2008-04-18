From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: catch signed nla_len() retval in tcf_simp_init()
Date: Thu, 17 Apr 2008 23:20:21 -0700 (PDT)
Message-ID: <20080417.232021.72082620.davem@davemloft.net>
References: <4806C501.20300@tiscali.nl>
	<20080416.213712.78410382.davem@davemloft.net>
	<4806D847.2030806@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 12o3l@tiscali.nl, hadi@cyberus.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56025
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752864AbYDRGUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 02:20:22 -0400
In-Reply-To: <4806D847.2030806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 17 Apr 2008 06:55:35 +0200

> The change is also unnecessary because the attribute was
> already validated and the length can not be less than zero.
> 
> This patch changes it to only check for zero length.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Even though there have been discussions to do other things,
this patch moves things in the forward direction so I have
applied it.

Thanks.

