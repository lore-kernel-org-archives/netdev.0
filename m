From: David Miller <davem@davemloft.net>
Subject: Re: s2io: packet reordering with 2.6.25.4
Date: Wed, 25 Jun 2008 18:27:32 -0700 (PDT)
Message-ID: <20080625.182732.205144814.davem@davemloft.net>
References: <4862DEA4.8020305@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com
To: virtualphtn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751688AbYFZB1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 21:27:32 -0400
In-Reply-To: <4862DEA4.8020305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Quetchenbach <virtualphtn@gmail.com>
Date: Wed, 25 Jun 2008 17:11:16 -0700

> Is this a known issue? Is there anything that I can do to debug it
> further?

Reordering can and will happen quite naturally on an SMP
system under Linux.

Our TCP stack has heurstics which are able to successfully
detect reordering and cope with it just fine.

For UDP based applications, they need to be able to properly handle
reordering.  Even in a completely controlled network configuration,
reordering by external aspects of the network is still possible, so
even if Linux never reordered packets, the UDP applications would
still need to cope with this for correct operation.
