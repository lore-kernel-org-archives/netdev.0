From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Problem with commit a0ee18b9b7d3847976c6fb315c06a34fb296de0e
Date: Mon, 23 Apr 2007 23:17:40 +0200
Message-ID: <20070423211740.GE521@postel.suug.ch>
References: <200704231506.34410.ismail@pardus.org.tr> <20070423.115125.97295475.davem@davemloft.net> <200704232209.10288.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ismail =?iso-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55635 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754227AbXDWVRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 17:17:19 -0400
Content-Disposition: inline
In-Reply-To: <200704232209.10288.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ismail D?nmez <ismail@pardus.org.tr> 2007-04-23 22:09
> Yes I know the fix is in but I wondered why its creating such problems with 
> 2.6.18 kernel, guess it depends on some other commits.

As long as you apply the complete patch including the additional
sanity check for RTN_MAX it should work perfectly fine on 2.6.18.

I can't think of any connection between the patch and the errors
you are seeing.

Are you absolutely sure the errors you see are directly connected
to applying the patch?
