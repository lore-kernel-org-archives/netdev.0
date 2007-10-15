From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Consolidate the ip6_pol_route_(input|output) pair
Date: Mon, 15 Oct 2007 13:03:07 -0700 (PDT)
Message-ID: <20071015.130307.121313825.davem@davemloft.net>
References: <47135529.4010500@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932085AbXJOUDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 16:03:03 -0400
In-Reply-To: <47135529.4010500@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 15 Oct 2007 15:55:21 +0400

> The difference in both functions is in the "id" passed to
> the rt6_select, so just pass it as an extra argument from
> two outer helpers.
> 
> This is minus 60 lines of code and 360 bytes of .text
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Excellent cleanup, applied!
