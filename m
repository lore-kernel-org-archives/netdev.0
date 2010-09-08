From: David Miller <davem@davemloft.net>
Subject: Re: Problems obtaining software TX timestamps
Date: Wed, 08 Sep 2010 14:24:01 -0700 (PDT)
Message-ID: <20100908.142401.233712108.davem@davemloft.net>
References: <4C877D8A.6040002@edu.uni-klu.ac.at>
	<1283958771.2748.85.camel@edumazet-laptop>
	<4C87FE60.7090209@edu.uni-klu.ac.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ikofler@edu.uni-klu.ac.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60904
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754807Ab0IHVXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:23:43 -0400
In-Reply-To: <4C87FE60.7090209@edu.uni-klu.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Kofler <ikofler@edu.uni-klu.ac.at>
Date: Wed, 08 Sep 2010 23:21:36 +0200

> Ok, for hardware timestamps it seems logically for me that the driver
> has to support this. But what about the software timestamps - do they
> also require support from the driver? Is there no generic
> implementation in the networking stack?

Each and every driver must add the hook because it must be inside of
the driver's transmit function due to packet lifetime issues etc.
