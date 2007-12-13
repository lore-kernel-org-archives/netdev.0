From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 12:38:40 -0800 (PST)
Message-ID: <20071213.123840.241818979.davem@davemloft.net>
References: <476181C1.3060204@myri.com>
	<20071213.110928.26060224.davem@davemloft.net>
	<4761896B.7070801@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, joonwpark81@gmail.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, jesse.brandeburg@intel.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57385
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754154AbXLMUil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 15:38:41 -0500
In-Reply-To: <4761896B.7070801@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 13 Dec 2007 11:35:07 -0800

> How about allowing a return value of -1 from napi_poll and letting
> device check itself.

It doesn't avoid the code duplication in the ->poll() fast paths.

I don't care, on the other hand, if crap accumulates in non-critical
slow paths like napi_disable() and dev_close().  That's why I'm
suggesting solutions in that area.
