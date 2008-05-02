From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] [BNX2]: Fix remote PHY initial link state.
Date: Fri, 02 May 2008 16:58:38 -0700 (PDT)
Message-ID: <20080502.165838.152824306.davem@davemloft.net>
References: <1209595861.7941.61.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60375
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935580AbYEBX6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:58:38 -0400
In-Reply-To: <1209595861.7941.61.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 30 Apr 2008 15:51:01 -0700

> [BNX2]: Fix remote PHY initial link state.
> 
> On some remote PHY blade systems, the driver receives no initial link
> interrupt.  As a result, the GMII/MII MAC mode does not get setup properly.
> To fix this problem, we add an initial poll of the link state after chip
> reset.
> 
> With this change, the setting of the initial carrier state in the init
> code can be eliminated.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
