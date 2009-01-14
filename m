From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/34]bnx2x: Barriers for the compiler
Date: Wed, 14 Jan 2009 13:13:56 -0800 (PST)
Message-ID: <20090114.131356.63668949.davem@davemloft.net>
References: <1231951364.11301.123.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756807AbZANVNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 16:13:54 -0500
In-Reply-To: <1231951364.11301.123.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:42:44 +0200

> To make sure no swapping are made by the compiler, changed HAS_WORK to inline
> functions and added all the necessary barriers
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Don't you need cpu memory barriers too?  What if the cpu reorders what
you're trying to order using just a compiler barrier?
