From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] export SAD info
Date: Thu, 26 Apr 2007 00:18:50 -0700 (PDT)
Message-ID: <20070426.001850.55508944.davem@davemloft.net>
References: <1177515761.9923.3.camel@localhost>
	<1177516490.9923.7.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54787
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933227AbXDZHSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:18:42 -0400
In-Reply-To: <1177516490.9923.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 25 Apr 2007 11:54:50 -0400

> That patch has xfrm_state_num being mucked with; just ignore that bit.
> I need to send a patch against net-2.6.22 and i will clean that up -
> just need some feedback.
> 
> Would it make sense to have those vars as u32 instead of unsigned int?

I'm ambivalent, "unsigned int" happens to be 32-bit on every platform.
So changing it would cause no harm :-)
