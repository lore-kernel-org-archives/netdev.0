From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: allow timestamps even if SYN packet has tsval=0
Date: Wed, 11 Mar 2009 06:47:10 -0700 (PDT)
Message-ID: <20090311.064710.255854254.davem@davemloft.net>
References: <49B7ABF2.5040803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754326AbZCKNrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 09:47:24 -0400
In-Reply-To: <49B7ABF2.5040803@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 11 Mar 2009 13:17:54 +0100

> So apparently WindowsXP sends a NULL tsval in SYN packet, then
> subsequent packets get a real value (60498) in this case.
> 
> This seems to work on other OS as well, so is the following patch
> considered evil ?  Do we have security concerns or only risking
> windows client to have slightly wrong rtt estimation at the begining
> of the tcp session ?

I think we'll have to accept this.

I don't see other systems blocking initial ts_ecn values of
zero like we do.
